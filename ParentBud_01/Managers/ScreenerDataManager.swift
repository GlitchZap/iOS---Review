//
//  ScreenerDataManager.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 07/11/25.
//

import Foundation

class ScreenerDataManager {
    static let shared = ScreenerDataManager()
    
    private let responsesKey = "screener_responses"
    private let profileKey = "user_profile"
    
    private var responses: [String: UserResponse] = [:]
    
    // ✅ NEW: Track if we're adding or editing a child
    var isAddingNewChild = false
    var editingChildId: String?
    
    private init() {
        loadResponses()
    }
    
    // MARK: - User Profile (now using UserData)
    var userProfile: UserData? {
        get {
            return UserDataManager.shared.getCurrentUser()
        }
        set {
            if let user = newValue {
                UserDataManager.shared.updateUser(user)
            }
        }
    }
    
    // MARK: - Save Response
    func saveResponse(questionId: String, response: UserResponse) {
        responses[questionId] = response
        saveResponses()
        print("Saved response for \(questionId)")
    }
    
    // MARK: - Save Response (Convenience method)
    func saveResponse(for questionId: String, selectedOptions: [String] = [], textInput: String? = nil) {
        let response = UserResponse(questionId: questionId, selectedOptions: selectedOptions, textInput: textInput)
        saveResponse(questionId: questionId, response: response)
    }
    
    // MARK: - Get Response
    func getResponse(for questionId: String) -> UserResponse? {
        return responses[questionId]
    }
    
    // MARK: - Get All Responses
    func getAllResponses() -> [String: UserResponse] {
        return responses
    }
    
    // MARK: - Check if all questions are answered
    func areAllQuestionsAnswered() -> Bool {
        let requiredQuestions = ["q1", "q2", "q3", "q4", "q5", "q6", "q7"]
        return requiredQuestions.allSatisfy { responses[$0] != nil }
    }
    
    // MARK: - Calculate Progress
    func getProgress() -> Float {
        let totalQuestions = 7
        let answeredQuestions = responses.count
        return Float(answeredQuestions) / Float(totalQuestions)
    }
    
    // ✅ UPDATED: Build User Profile from Responses - Support multiple children with age groups
    func buildUserProfile() {
        guard var currentUser = UserDataManager.shared.getCurrentUser() else {
            print("No current user to update")
            return
        }
        
        // ✅ NEW: Handle adding new child vs editing existing
        if isAddingNewChild {
            buildNewChildProfile()
        } else if let editingId = editingChildId {
            updateExistingChildProfile(childId: editingId)
        } else {
            // Original behavior for initial screener
            buildInitialUserProfile()
        }
    }
    
    // ✅ NEW: Build new child profile and add to existing user
    private func buildNewChildProfile() {
        guard let user = UserDataManager.shared.getCurrentUser() else {
            print("No current user to add child to")
            return
        }
        
        // Extract child information from responses
        guard let childName = responses["q5"]?.textInput,
              let childAgeGroup = responses["q4"]?.selectedOptions.first else {
            print("❌ Missing required child information")
            return
        }
        
        let childTemperament = responses["q6"]?.selectedOptions
        let supportAreas = responses["q7"]?.selectedOptions
        
        // ✅ UPDATED: Create new child with age group stored in child
        let newChild = ChildData(
            name: childName,
            age: extractAge(from: childAgeGroup),
            ageGroup: childAgeGroup,  // ✅ Store age group in child
            temperament: childTemperament,
            currentFocus: supportAreas
        )
        
        // Add to user's child profiles and set as active
        UserDataManager.shared.addChildProfile(newChild, setAsActive: true)
        
        print("✅ Added new child profile: \(childName) with age group: \(childAgeGroup)")
        clearResponses()
        resetFlags()
    }
    
    // ✅ UPDATED: Update existing child profile with age group
    private func updateExistingChildProfile(childId: String) {
        guard var user = UserDataManager.shared.getCurrentUser() else {
            print("No current user")
            return
        }
        
        guard let childIndex = user.childProfiles.firstIndex(where: { $0.id == childId }) else {
            print("❌ Child not found: \(childId)")
            return
        }
        
        var child = user.childProfiles[childIndex]
        
        // Update child with new information
        if let childName = responses["q5"]?.textInput {
            child.name = childName
        }
        
        if let childAgeGroup = responses["q4"]?.selectedOptions.first {
            child.age = extractAge(from: childAgeGroup)
            child.ageGroup = childAgeGroup  // ✅ Update age group in child
        }
        
        if let temperament = responses["q6"]?.selectedOptions {
            child.temperament = temperament
        }
        
        if let supportAreas = responses["q7"]?.selectedOptions {
            child.currentFocus = supportAreas
        }
        
        UserDataManager.shared.updateChildProfile(child)
        
        print("✅ Updated child profile: \(child.name) with age group: \(child.ageGroup ?? "N/A")")
        clearResponses()
        resetFlags()
    }
    
    // ✅ UPDATED: Build initial user profile with age group in child
    private func buildInitialUserProfile() {
        guard var currentUser = UserDataManager.shared.getCurrentUser() else {
            print("No current user to update")
            return
        }
        
        var screenerData = ScreenerData()
        
        // UPDATED: Map responses to NEW question order
        // Q1: Parent Role
        if let q1 = responses["q1"] {
            screenerData.parentRole = q1.selectedOptions.first
        }
        
        // Q2: Family Structure
        if let q2 = responses["q2"] {
            screenerData.familyStructure = q2.selectedOptions.first
        }
        
        // Q3: Employment Status
        if let q3 = responses["q3"] {
            screenerData.employmentStatus = q3.selectedOptions.first
        }
        
        // Q4: Child Age Group
        if let q4 = responses["q4"] {
            screenerData.childAgeGroup = q4.selectedOptions.first
        }
        
        // Q5: Child Name
        if let q5 = responses["q5"] {
            screenerData.childName = q5.textInput
        }
        
        // Q6: Child Temperament
        if let q6 = responses["q6"] {
            screenerData.childTemperament = q6.selectedOptions
        }
        
        // Q7: Support Areas
        if let q7 = responses["q7"] {
            screenerData.supportAreas = q7.selectedOptions
        }
        
        screenerData.completedAt = Date()
        
        // Update user
        currentUser.screenerData = screenerData
        currentUser.hasCompletedScreener = true
        currentUser.hasCompletedOnboarding = true
        currentUser.updatedAt = Date()
        
        // ✅ UPDATED: Create child data with age group stored in child
        if let childName = screenerData.childName {
            let newChild = ChildData(
                name: childName,
                age: extractAge(from: screenerData.childAgeGroup),
                ageGroup: screenerData.childAgeGroup,  // ✅ Store age group in child
                temperament: screenerData.childTemperament,
                currentFocus: screenerData.supportAreas
            )
            
            currentUser.childProfiles = [newChild]
            currentUser.activeChildId = newChild.id
        }
        
        UserDataManager.shared.updateUser(currentUser)
        
        print("Built and saved initial user profile")
        clearResponses()
        printProfile()
    }
    
    // ✅ NEW: Helper methods
    private func resetFlags() {
        isAddingNewChild = false
        editingChildId = nil
    }
    
    private func clearResponses() {
        responses.removeAll()
        saveResponses()
    }
    
    private func extractAge(from ageGroup: String?) -> Int? {
        guard let ageGroup = ageGroup?.lowercased() else { return nil }
        if ageGroup.contains("2-4") { return 3 }
        if ageGroup.contains("5-7") { return 6 }
        if ageGroup.contains("8-10") { return 9 }
        // Legacy support for old age groups
        if ageGroup.contains("infant") || ageGroup.contains("0-1") { return 1 }
        if ageGroup.contains("toddler") { return 3 }
        if ageGroup.contains("preschool") || ageGroup.contains("3-5") { return 4 }
        if ageGroup.contains("school") || ageGroup.contains("6-12") { return 7 }
        return nil
    }
    
    // ✅ UPDATED: Load existing child data for editing with age group
    func loadExistingChildData(childId: String) {
        guard let user = UserDataManager.shared.getCurrentUser(),
              let child = user.childProfiles.first(where: { $0.id == childId }) else {
            print("❌ Child not found for editing: \(childId)")
            return
        }
        
        // Clear existing responses
        responses.removeAll()
        
        // ✅ UPDATED: Pre-populate responses with child's age group
        if let childAgeGroup = child.ageGroup {
            saveResponse(for: "q4", selectedOptions: [childAgeGroup])
        }
        
        saveResponse(for: "q5", textInput: child.name)
        
        if let temperament = child.temperament {
            saveResponse(for: "q6", selectedOptions: temperament)
        }
        
        if let focus = child.currentFocus {
            saveResponse(for: "q7", selectedOptions: focus)
        }
        
        editingChildId = childId
        print("✅ Loaded existing child data for editing: \(child.name) with age group: \(child.ageGroup ?? "N/A")")
    }
    
    // MARK: - Print Profile (Debug) - ✅ UPDATED for multiple children
    func printProfile() {
        guard let user = UserDataManager.shared.getCurrentUser(),
              let screenerData = user.screenerData else {
            print("No profile data available")
            return
        }
        
        print("\n" + String(repeating: "=", count: 50))
        print("USER PROFILE")
        print(String(repeating: "=", count: 50))
        print("Name: \(user.name)")
        print("Email: \(user.email)")
        print("Parent Role: \(screenerData.parentRole ?? "N/A")")
        print("Child Profiles: \(user.childProfiles.count)")
        for child in user.childProfiles {
            let isActive = child.id == user.activeChildId ? " (ACTIVE)" : ""
            print("  - \(child.name), Age Group: \(child.ageGroup ?? "N/A")\(isActive)")
        }
        print("Family Structure: \(screenerData.familyStructure ?? "N/A")")
        print("Employment: \(screenerData.employmentStatus ?? "N/A")")
        print("Support Areas: \(screenerData.supportAreas?.joined(separator: ", ") ?? "N/A")")
        print("Completed: \(screenerData.isComplete ? "Yes" : "No")")
        print("Progress: \(screenerData.completionPercentage)%")
        print(String(repeating: "=", count: 50) + "\n")
    }
    
    // MARK: - Clear Response (For back button)
    func clearResponse(for questionId: String) {
        responses.removeValue(forKey: questionId)
        saveResponses()
        print("Cleared response for \(questionId)")
    }
    
    // MARK: - Persistence
    private func saveResponses() {
        if let encoded = try? JSONEncoder().encode(responses) {
            UserDefaults.standard.set(encoded, forKey: responsesKey)
        }
    }
    
    private func loadResponses() {
        if let data = UserDefaults.standard.data(forKey: responsesKey),
           let decoded = try? JSONDecoder().decode([String: UserResponse].self, from: data) {
            responses = decoded
            print("Loaded \(responses.count) screener responses")
        }
    }
    
    // MARK: - Clear All Data
    func clearAllData() {
        responses.removeAll()
        UserDefaults.standard.removeObject(forKey: responsesKey)
        UserDefaults.standard.removeObject(forKey: profileKey)
        resetFlags()
        print("Cleared all screener data")
    }
    
    // MARK: - Validation (UPDATED)
    func validateResponse(questionId: String, response: UserResponse) -> Bool {
        switch questionId {
        case "q1", "q2", "q3", "q4": // Single select (Tell us about yourself)
            return !response.selectedOptions.isEmpty
        case "q5": // Text input (Child name)
            return response.textInput?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty == false
        case "q6", "q7": // Multi-select (Tell us about your little one)
            return !response.selectedOptions.isEmpty
        default:
            return false
        }
    }
}
