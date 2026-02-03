//
//  UserData.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 07/11/25.
//

import Foundation

// MARK: - User Data Model
struct UserData: Codable {
    let userId: String
    var email: String
    var name: String
    var phoneNumber: String?
    let createdAt: Date
    var updatedAt: Date
    var lastLoginAt: Date
    var hasCompletedOnboarding: Bool
    var hasCompletedScreener: Bool
    var screenerData: ScreenerData?
    
    // NEW: Multiple child profiles support
    var childProfiles: [ChildData]
    var activeChildId: String?
    
    // LEGACY: Keep for backward compatibility
    var childData: ChildData? {
        get {
            guard let activeChildId = activeChildId else {
                return childProfiles.first
            }
            return childProfiles.first { $0.id == activeChildId }
        }
        set {
            if let newChild = newValue {
                // If this child doesn't exist, add it
                if !childProfiles.contains(where: { $0.id == newChild.id }) {
                    childProfiles.append(newChild)
                }
                activeChildId = newChild.id
            }
        }
    }
    
    init(userId: String = UUID().uuidString,
         email: String = "",
         name: String = "",
         phoneNumber: String? = nil,
         createdAt: Date = Date(),
         updatedAt: Date = Date(),
         lastLoginAt: Date = Date(),
         hasCompletedOnboarding: Bool = false,
         hasCompletedScreener: Bool = false,
         screenerData: ScreenerData? = nil,
         childData: ChildData? = nil,
         childProfiles: [ChildData] = [],
         activeChildId: String? = nil) {
        self.userId = userId
        self.email = email
        self.name = name
        self.phoneNumber = phoneNumber
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastLoginAt = lastLoginAt
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.hasCompletedScreener = hasCompletedScreener
        self.screenerData = screenerData
        
        // Handle migration from single child to multiple children
        if !childProfiles.isEmpty {
            self.childProfiles = childProfiles
            self.activeChildId = activeChildId ?? childProfiles.first?.id
        } else if let childData = childData {
            self.childProfiles = [childData]
            self.activeChildId = childData.id
        } else {
            self.childProfiles = []
            self.activeChildId = nil
        }
    }
}

// MARK: - Screener Data Model
struct ScreenerData: Codable {
    var parentRole: String?                    // q1: Parent, Single Parent, Caregiver
    var childName: String?                     // q2: Text input
    var familyStructure: String?               // q3: Nuclear Family, Joint Family
    var childTemperament: [String]?            // q4: Easy Going, Sensitive, etc.
    var employmentStatus: String?              // q5: Working, Not Working
    var supportAreas: [String]?                // q6: Sleep, Tantrums, etc. (challengesFaced)
    var childAgeGroup: String?                 // q7: Age range - KEPT for backward compatibility
    var completedAt: Date?
    
    // Legacy compatibility
    var parentingStyle: String? {
        get { return parentRole }
        set { parentRole = newValue }
    }
    
    var challengesFaced: [String]? {
        get { return supportAreas }
        set { supportAreas = newValue }
    }
    
    // Metadata
    var isComplete: Bool {
        return parentRole != nil &&
               childName != nil &&
               childAgeGroup != nil &&
               !(supportAreas?.isEmpty ?? true)
    }
    
    var completionPercentage: Int {
        var completed = 0
        let total = 7
        
        if parentRole != nil { completed += 1 }
        if childName != nil { completed += 1 }
        if familyStructure != nil { completed += 1 }
        if childTemperament != nil { completed += 1 }
        if employmentStatus != nil { completed += 1 }
        if supportAreas != nil { completed += 1 }
        if childAgeGroup != nil { completed += 1 }
        
        return (completed * 100) / total
    }
    
    init(parentRole: String? = nil,
         childName: String? = nil,
         familyStructure: String? = nil,
         childTemperament: [String]? = nil,
         employmentStatus: String? = nil,
         supportAreas: [String]? = nil,
         childAgeGroup: String? = nil,
         completedAt: Date? = nil) {
        self.parentRole = parentRole
        self.childName = childName
        self.familyStructure = familyStructure
        self.childTemperament = childTemperament
        self.employmentStatus = employmentStatus
        self.supportAreas = supportAreas
        self.childAgeGroup = childAgeGroup
        self.completedAt = completedAt
    }
}

// MARK: - UPDATED Child Data Model - Now includes age group per child
struct ChildData: Codable, Identifiable {
    let id: String
    var name: String
    var age: Int?
    var ageGroup: String?
    var temperament: [String]?
    var currentFocus: [String]?
    let createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString,
         name: String,
         age: Int? = nil,
         ageGroup: String? = nil,
         temperament: [String]? = nil,
         currentFocus: [String]? = nil,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.age = age
        self.ageGroup = ageGroup
        self.temperament = temperament
        self.currentFocus = currentFocus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
