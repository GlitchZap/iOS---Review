//
//  UserDataManager.swift
//  ParentBud_01
//
//  Created by GlitchZap on 12/11/25.
//

import Foundation
import Auth

// MARK: - User Data Manager
class UserDataManager {
    static let shared = UserDataManager()
    private let authService = SupabaseAuthService.shared
    private let profileService = SupabaseProfileService.shared
    
    private let usersFileName = "users_data.json"
    private let currentUserKey = "current_user_id"
    
    private var allUsers: [UserData] = []
    private var currentUser: UserData?
    
    private init() {
        loadAllUsers()
        loadCurrentUser()
    }

    // MARK: - Supabase-backed Auth
    @discardableResult
    func signIn(email: String, password: String) async throws -> UserData {
        try await authService.signIn(email: email, password: password)
        
        // Try to fetch from profiles table, but fallback to auth data if it fails
        var profile: UserData
        do {
            profile = try await profileService.fetchCurrentProfile()
        } catch {
            print("⚠️ Failed to fetch profile from Supabase (table may not exist): \(error)")
            // Create profile from auth data as fallback
            let user = try await authService.currentUser()
            profile = UserData(
                userId: user.id.uuidString,
                email: user.email ?? email,
                name: user.userMetadata["name"]?.stringValue ?? "",
                hasCompletedOnboarding: false,
                hasCompletedScreener: false
            )
        }
        
        cacheAndSetCurrentUser(profile)
        return profile
    }

    @discardableResult
    func signUp(email: String, password: String, name: String) async throws -> UserData {
        // Step 1: Create Supabase Auth user first (this populates auth.users table)
        print("🔄 Creating Supabase Auth user for: \(email)")
        try await authService.signUp(email: email, password: password, name: name)
        
        // Step 2: Get the created auth user
        let authUser = try await authService.currentUser()
        print("✅ Supabase Auth user created with ID: \(authUser.id)")

        // Step 3: Create profile data
        var profile = UserData(
            userId: authUser.id.uuidString,
            email: email,
            name: name,
            hasCompletedOnboarding: false,
            hasCompletedScreener: false
        )
        
        // Step 4: Try to save to Supabase profiles table
        do {
            print("🔄 Creating profile in Supabase profiles table...")
            try await profileService.upsertProfile(profile)
            
            // Try to fetch back the created profile to confirm
            profile = try await profileService.fetchCurrentProfile()
            print("✅ Successfully created and fetched profile from Supabase")
        } catch {
            print("⚠️ Failed to save profile to Supabase (table may not exist): \(error)")
            print("📝 Profile data that failed to save: \(profile)")
            // Continue with local profile data - auth user is still created
        }
        
        // Step 5: Cache locally and set as current user
        cacheAndSetCurrentUser(profile)
        print("✅ Sign up completed for user: \(name) (\(email))")
        
        return profile
    }

    @discardableResult
    func refreshCurrentUserFromRemote() async throws -> UserData {
        // Try to fetch from profiles table, but fallback to current user if it fails
        var profile: UserData
        do {
            profile = try await profileService.fetchCurrentProfile()
        } catch {
            print("⚠️ Failed to refresh profile from Supabase (table may not exist): \(error)")
            // Use current user data as fallback
            guard let currentUser = currentUser else {
                throw NSError(domain: "UserDataManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "No current user to refresh"])
            }
            profile = currentUser
        }
        
        cacheAndSetCurrentUser(profile)
        return profile
    }
    
    // MARK: - File URL
    private func getUsersFileURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(usersFileName)
    }
    
    // MARK: - Load All Users
    private func loadAllUsers() {
        let fileURL = getUsersFileURL()
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("📂 Users file not found, creating with default users...")
            createDefaultUsers()
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            allUsers = try decoder.decode([UserData].self, from: data)
            print("✅ Loaded \(allUsers.count) users from JSON")
            
            // ✅ Migrate users to new multiple children structure
            migrateUsersIfNeeded()
        } catch {
            print("❌ Error loading users: \(error)")
            createDefaultUsers()
        }
    }
    
    // ✅ NEW: Migration from single child to multiple children with age group per child
    private func migrateUsersIfNeeded() {
        var needsSave = false
        
        for i in 0..<allUsers.count {
            var user = allUsers[i]
            
            // If user has old structure, migrate
            if user.childProfiles.isEmpty, let _ = user.childData {
                print("🔄 Migrating user \(user.name) to multiple child profiles structure")
                // The UserData init will handle the migration automatically
                user = UserData(
                    userId: user.userId,
                    email: user.email,
                    name: user.name,
                    phoneNumber: user.phoneNumber,
                    createdAt: user.createdAt,
                    updatedAt: user.updatedAt,
                    lastLoginAt: user.lastLoginAt,
                    hasCompletedOnboarding: user.hasCompletedOnboarding,
                    hasCompletedScreener: user.hasCompletedScreener,
                    screenerData: user.screenerData,
                    childData: user.childData
                )
                allUsers[i] = user
                needsSave = true
            }
            
            // ✅ NEW: Migrate children without ageGroup to have ageGroup from screenerData
            var childrenUpdated = false
            for j in 0..<user.childProfiles.count {
                var child = user.childProfiles[j]
                if child.ageGroup == nil, let userAgeGroup = user.screenerData?.childAgeGroup {
                    child.ageGroup = userAgeGroup
                    user.childProfiles[j] = child
                    childrenUpdated = true
                    print("🔄 Migrated child \(child.name) to include age group: \(userAgeGroup)")
                }
            }
            
            if childrenUpdated {
                allUsers[i] = user
                needsSave = true
            }
        }
        
        if needsSave {
            saveAllUsers()
            print("✅ Migration completed")
        }
    }
    
    // MARK: - Save All Users
    private func saveAllUsers() {
        let fileURL = getUsersFileURL()
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(allUsers)
            try data.write(to: fileURL)
            print("✅ Saved \(allUsers.count) users to JSON")
        } catch {
            print("❌ Error saving users: \(error)")
        }
    }
    
    // MARK: - Create Default Users
    private func createDefaultUsers() {
        let child1 = ChildData(
            name: "Mia",
            age: 3,
            ageGroup: "2-4 years (toddler & preschool years)",
            temperament: ["Sensitive", "Cautious"],
            currentFocus: ["Sleep routines", "Tantrums", "Eating Habits"]
        )
        
        let child2 = ChildData(
            name: "Rohan",
            age: 6,
            ageGroup: "5-7 years (early school years)",
            temperament: ["Easy Going", "Spirited"],
            currentFocus: ["Screen Time", "Social Skills", "Behaviour Management"]
        )
        
        allUsers = [
            UserData(
                userId: "user_001",
                email: "testuser@gmail.com",
                name: "Niharika",
                hasCompletedOnboarding: true,
                hasCompletedScreener: true,
                screenerData: ScreenerData(
                    parentRole: "Parent",
                    childName: "Mia",
                    familyStructure: "Nuclear Family",
                    childTemperament: ["Sensitive", "Cautious"],
                    employmentStatus: "Working",
                    supportAreas: ["Sleep Routines", "Tantrums", "Eating Habits"],
                    childAgeGroup: "2-4 years (toddler & preschool years)",
                    completedAt: Date()
                ),
                childProfiles: [child1],
                activeChildId: child1.id
            ),
            UserData(
                userId: "user_002",
                email: "aayush@example.com",
                name: "Aayush",
                hasCompletedOnboarding: true,
                hasCompletedScreener: true,
                screenerData: ScreenerData(
                    parentRole: "Parent",
                    childName: "Rohan",
                    familyStructure: "Joint Family",
                    childTemperament: ["Easy Going", "Spirited"],
                    employmentStatus: "Working",
                    supportAreas: ["Screen Time", "Social Skills", "Behaviour Management"],
                    childAgeGroup: "5-7 years (early school years)",
                    completedAt: Date()
                ),
                childProfiles: [child2],
                activeChildId: child2.id
            )
        ]
        
        saveAllUsers()
        print("✅ Created 2 default users with child profiles")
    }
    
    // MARK: - Load Current User
    private func loadCurrentUser() {
        guard let userId = UserDefaults.standard.string(forKey: currentUserKey) else {
            print("📭 No current user set")
            return
        }
        
        currentUser = allUsers.first(where: { $0.userId == userId })
        if let user = currentUser {
            UserDefaults.standard.set(user.name, forKey: "userName")
            print("✅ Loaded current user: \(user.name)")
        }
    }
    
    // MARK: - Login User (by email)
    func loginUser(email: String) -> Bool {
        guard let user = allUsers.first(where: { $0.email.lowercased() == email.lowercased() }) else {
            print("❌ User not found: \(email)")
            return false
        }
        
        if let index = allUsers.firstIndex(where: { $0.userId == user.userId }) {
            allUsers[index].lastLoginAt = Date()
            allUsers[index].updatedAt = Date()
            saveAllUsers()
        }
        
        currentUser = user
        UserDefaults.standard.set(user.userId, forKey: currentUserKey)
        UserDefaults.standard.set(user.name, forKey: "userName")
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        UserDefaults.standard.set(email, forKey: "userEmail")
        
        print("✅ User logged in: \(user.name)")
        return true
    }
    
    // MARK: - Get Current User
    func getCurrentUser() -> UserData? {
        return currentUser
    }
    
    // MARK: - Update Current User
    func updateUser(_ user: UserData) {
        if let index = allUsers.firstIndex(where: { $0.userId == user.userId }) {
            var updatedUser = user
            updatedUser.updatedAt = Date()
            allUsers[index] = updatedUser
            saveAllUsers()
            
            if currentUser?.userId == user.userId {
                currentUser = updatedUser
            }
            
            print("✅ Updated user locally: \(user.name)")

            // Mirror to Supabase with proper error handling
            Task {
                do {
                    try await self.profileService.upsertProfile(updatedUser)
                    print("✅ Successfully synced user to Supabase: \(user.name)")
                } catch {
                    print("⚠️ Failed to sync user to Supabase: \(error)")
                    // Could implement retry logic here if needed
                }
            }
        }
    }
    
    // ✅ NEW: Child Profile Management Methods
    
    // Add a new child profile
    func addChildProfile(_ child: ChildData, setAsActive: Bool = true) {
        guard var user = currentUser else {
            print("❌ No current user to add child to")
            return
        }
        
        user.childProfiles.append(child)
        
        if setAsActive || user.activeChildId == nil {
            user.activeChildId = child.id
        }
        
        updateUser(user)
        print("✅ Added child profile: \(child.name) with age group: \(child.ageGroup ?? "N/A")")
    }
    
    // Remove a child profile
    func removeChildProfile(withId childId: String) {
        guard var user = currentUser else {
            print("❌ No current user")
            return
        }
        
        user.childProfiles.removeAll { $0.id == childId }
        
        // If we removed the active child, set a new active child
        if user.activeChildId == childId {
            user.activeChildId = user.childProfiles.first?.id
        }
        
        updateUser(user)
        print("✅ Removed child profile: \(childId)")
    }
    
    // Set active child profile
    func setActiveChild(childId: String) {
        guard var user = currentUser else {
            print("❌ No current user")
            return
        }
        
        guard user.childProfiles.contains(where: { $0.id == childId }) else {
            print("❌ Child not found: \(childId)")
            return
        }
        
        user.activeChildId = childId
        updateUser(user)
        print("✅ Set active child: \(childId)")
    }
    
    // Get active child profile
    func getActiveChildProfile() -> ChildData? {
        return currentUser?.childData
    }
    
    // Get all child profiles
    func getAllChildProfiles() -> [ChildData] {
        return currentUser?.childProfiles ?? []
    }
    
    // ✅ UPDATED: Update a specific child profile
    func updateChildProfile(_ child: ChildData) {
        guard var user = currentUser else {
            print("❌ No current user")
            return
        }
        
        if let index = user.childProfiles.firstIndex(where: { $0.id == child.id }) {
            var updatedChild = child
            updatedChild.updatedAt = Date()
            user.childProfiles[index] = updatedChild
            updateUser(user)
            print("✅ Updated child profile: \(child.name) with age group: \(child.ageGroup ?? "N/A")")
        } else {
            print("❌ Child profile not found: \(child.id)")
        }
    }
    
    // MARK: - Get All Users
    func getAllUsers() -> [UserData] {
        return allUsers
    }
    
    // MARK: - Create New User
    func createNewUser(email: String, name: String, password: String) -> UserData {
        let newUser = UserData(
            userId: "user_\(UUID().uuidString.prefix(8))",
            email: email,
            name: name,
            hasCompletedOnboarding: false,
            hasCompletedScreener: false
        )
        
        allUsers.append(newUser)
        saveAllUsers()
        
        currentUser = newUser
        UserDefaults.standard.set(newUser.userId, forKey: currentUserKey)
        UserDefaults.standard.set(newUser.name, forKey: "userName")
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        UserDefaults.standard.set(email, forKey: "userEmail")
        
        print("✅ Created new user: \(name)")
        return newUser
    }
    
    // MARK: - ✅ UPDATED: Update Screener Data for multiple children
    func updateScreenerData(responses: [String: UserResponse]) {
        guard var user = currentUser else {
            print("❌ No current user to update")
            return
        }
        
        var screenerData = ScreenerData()
        
        for (questionId, response) in responses {
            switch questionId {
            case "q1":
                screenerData.parentRole = response.selectedOptions.first
            case "q2":
                screenerData.familyStructure = response.selectedOptions.first
            case "q3":
                screenerData.employmentStatus = response.selectedOptions.first
            case "q4":
                screenerData.childAgeGroup = response.selectedOptions.first
            case "q5":
                screenerData.childName = response.textInput
            case "q6":
                screenerData.childTemperament = response.selectedOptions
            case "q7":
                screenerData.supportAreas = response.selectedOptions
            default:
                break
            }
        }
        
        screenerData.completedAt = Date()
        user.screenerData = screenerData
        user.hasCompletedScreener = true
        user.hasCompletedOnboarding = true
        user.updatedAt = Date()
        
        // ✅ UPDATED: Create child data with age group stored in child
        if let childName = screenerData.childName {
            let newChild = ChildData(
                name: childName,
                age: extractAge(from: screenerData.childAgeGroup),
                ageGroup: screenerData.childAgeGroup,  // ✅ Store age group in child
                temperament: screenerData.childTemperament,
                currentFocus: screenerData.supportAreas
            )
            
            user.childProfiles = [newChild]
            user.activeChildId = newChild.id
        }
        
        updateUser(user)
        print("✅ Updated screener data and added new child profile for user: \(user.name)")
        
        // ✅ Force sync to Supabase after screener completion
        Task {
            do {
                try await self.profileService.upsertProfile(user)
                print("✅ Successfully synced screener data to Supabase for user: \(user.name)")
            } catch {
                print("⚠️ Failed to sync screener data to Supabase: \(error)")
            }
        }
    }
    
    private func extractAge(from ageGroup: String?) -> Int? {
        guard let ageGroup = ageGroup?.lowercased() else { return nil }
        if ageGroup.contains("2-4") { return 3 }
        if ageGroup.contains("5-7") { return 6 }
        if ageGroup.contains("8-10") { return 9 }
        return nil
    }
    
    // MARK: - Check User Exists
    func userExists(email: String) -> Bool {
        return allUsers.contains(where: { $0.email.lowercased() == email.lowercased() })
    }
    
    // MARK: - Logout
    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: currentUserKey)
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "isUserLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userEmail")

        Task {
            try? await self.authService.signOut()
        }
        print("🚪 User logged out")
    }
    
    // MARK: - Clear All Data (for testing)
    func clearAllData() {
        let fileURL = getUsersFileURL()
        try? FileManager.default.removeItem(at: fileURL)
        allUsers = []
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: currentUserKey)
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "isUserLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        print("🗑️ Cleared all user data")
    }
    
    // MARK: - Print All Users (Debug)
    func printAllUsers() {
        print("\n" + String(repeating: "=", count: 50))
        print("👥 ALL USERS IN JSON")
        print(String(repeating: "=", count: 50))
        
        for user in allUsers {
            print("\n📧 Email: \(user.email)")
            print("👤 Name: \(user.name)")
            print("🎓 Onboarding: \(user.hasCompletedOnboarding ? "✅" : "❌")")
            print("✅ Screener: \(user.hasCompletedScreener ? "Complete" : "Incomplete")")
            print("👶 Children: \(user.childProfiles.count)")
            
            for child in user.childProfiles {
                let isActive = child.id == user.activeChildId ? " (ACTIVE)" : ""
                print("  - \(child.name), Age Group: \(child.ageGroup ?? "N/A")\(isActive)")
            }
        }
        
        print("\nCurrent User: \(currentUser?.name ?? "None")")
        print(String(repeating: "=", count: 50) + "\n")
    }

    // MARK: - Helpers
    private func cacheAndSetCurrentUser(_ user: UserData) {
        currentUser = user
        if let index = allUsers.firstIndex(where: { $0.userId == user.userId }) {
            allUsers[index] = user
        } else {
            allUsers.append(user)
        }
        saveAllUsers()
        UserDefaults.standard.set(user.userId, forKey: currentUserKey)
        UserDefaults.standard.set(user.name, forKey: "userName")
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        UserDefaults.standard.set(user.email, forKey: "userEmail")
    }
}
