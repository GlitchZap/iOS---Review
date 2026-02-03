//
//  SettingsDataManager.swift
//  ParentBud_01
//
//  Created by Lovansh1245 on 2025-11-17
//

import Foundation

class SettingsDataManager {
    static let shared = SettingsDataManager()
    
    private let childProfilesKey = "child_profiles"
    private let notificationSettingsKey = "notification_settings"
    private let privacySettingsKey = "privacy_settings"
    
    private init() {}
    
    // MARK: - Child Profiles Management
    
    func saveChildProfile(_ profile: ChildProfile) {
        var profiles = getAllChildProfiles()
        
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            var updatedProfile = profile
            updatedProfile.updatedAt = Date()
            profiles[index] = updatedProfile
            print("Updated child profile: \(profile.name)")
        } else {
            profiles.append(profile)
            print("Added new child profile: \(profile.name)")
        }
        
        saveChildProfiles(profiles)
    }
    
    func getAllChildProfiles() -> [ChildProfile] {
        guard let data = UserDefaults.standard.data(forKey: childProfilesKey),
              let profiles = try? JSONDecoder().decode([ChildProfile].self, from: data) else {
            print("No child profiles found")
            return []
        }
        print("Loaded \(profiles.count) child profiles")
        return profiles.sorted { $0.createdAt > $1.createdAt }
    }
    
    func getChildProfile(byId id: UUID) -> ChildProfile? {
        return getAllChildProfiles().first { $0.id == id }
    }
    
    func deleteChildProfile(_ id: UUID) {
        var profiles = getAllChildProfiles()
        profiles.removeAll { $0.id == id }
        saveChildProfiles(profiles)
        print("Deleted child profile: \(id)")
    }
    
    private func saveChildProfiles(_ profiles: [ChildProfile]) {
        if let encoded = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(encoded, forKey: childProfilesKey)
            print("Saved \(profiles.count) child profiles")
        }
    }
    
    // MARK: - Notification Settings
    
    func getNotificationSettings() -> NotificationSettings {
        guard let data = UserDefaults.standard.data(forKey: notificationSettingsKey),
              let settings = try? JSONDecoder().decode(NotificationSettings.self, from: data) else {
            return NotificationSettings()
        }
        return settings
    }
    
    func saveNotificationSettings(_ settings: NotificationSettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: notificationSettingsKey)
            print("Notification settings saved")
        }
    }
    
    // MARK: - Privacy Settings
    
    func getPrivacySettings() -> PrivacySettings {
        guard let data = UserDefaults.standard.data(forKey: privacySettingsKey),
              let settings = try? JSONDecoder().decode(PrivacySettings.self, from: data) else {
            return PrivacySettings()
        }
        return settings
    }
    
    func savePrivacySettings(_ settings: PrivacySettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: privacySettingsKey)
            print("Privacy settings saved")
        }
    }
    
    // MARK: - User Profile Phone Number
    
    func updatePhoneNumber(_ phoneNumber: String, for userId: String) {
        UserDefaults.standard.set(phoneNumber, forKey: "user_phone_\(userId)")
        print("Updated phone number for user: \(userId)")
    }
    
    func getPhoneNumber(for userId: String) -> String? {
        return UserDefaults.standard.string(forKey: "user_phone_\(userId)")
    }
    
    // MARK: - Clear All Settings Data
    
    func clearAllData() {
        UserDefaults.standard.removeObject(forKey: childProfilesKey)
        UserDefaults.standard.removeObject(forKey: notificationSettingsKey)
        UserDefaults.standard.removeObject(forKey: privacySettingsKey)
        print("Cleared all settings data")
    }
}

// MARK: - Supporting Models

struct NotificationSettings: Codable {
    var expertMessages: Bool
    var sessionReminders: Bool
    var newContent: Bool
    var communityUpdates: Bool
    
    init(expertMessages: Bool = true,
         sessionReminders: Bool = true,
         newContent: Bool = true,
         communityUpdates: Bool = false) {
        self.expertMessages = expertMessages
        self.sessionReminders = sessionReminders
        self.newContent = newContent
        self.communityUpdates = communityUpdates
    }
}

struct PrivacySettings: Codable {
    var profileVisibility: ProfileVisibility
    var dataSharing: Bool
    var analyticsTracking: Bool
    
    init(profileVisibility: ProfileVisibility = .private,
         dataSharing: Bool = false,
         analyticsTracking: Bool = true) {
        self.profileVisibility = profileVisibility
        self.dataSharing = dataSharing
        self.analyticsTracking = analyticsTracking
    }
}

enum ProfileVisibility: String, Codable {
    case `public` = "Public"
    case `private` = "Private"
    case friendsOnly = "Friends Only"
}
