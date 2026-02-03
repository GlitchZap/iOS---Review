//
//  ActivityFeedDataManager.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2025-11-14
//

import Foundation

class ActivityFeedDataManager {
    static let shared = ActivityFeedDataManager()
    
    private let userDefaults = UserDefaults.standard
    private let activityFeedKey = "activityFeedLogs"
    
    private init() {}
    
    func saveActivityLog(_ log: LogEntry) {
        var logs = getAllActivityLogs()
        
        if let index = logs.firstIndex(where: { $0.id == log.id }) {
            logs[index] = log
            print("✅ Updated existing activity log: \(log.id)")
        } else {
            logs.append(log)
            print("✅ Added new activity log: \(log.id)")
        }
        
        if let encoded = try? JSONEncoder().encode(logs) {
            userDefaults.set(encoded, forKey: activityFeedKey)
            print("✅ Saved \(logs.count) activity logs to UserDefaults")
        }
    }
    
    func getAllActivityLogs() -> [LogEntry] {
        guard let data = userDefaults.data(forKey: activityFeedKey),
              let logs = try? JSONDecoder().decode([LogEntry].self, from: data) else {
            print("⚠️ No activity logs found")
            return []
        }
        print("✅ Loaded \(logs.count) activity logs")
        return logs.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    func getLogs(byStatus status: LogStatus) -> [LogEntry] {
        let allLogs = getAllActivityLogs()
        return allLogs.filter { $0.status == status }
    }
    
    func getLog(byId id: UUID) -> LogEntry? {
        let allLogs = getAllActivityLogs()
        return allLogs.first { $0.id == id }
    }
    
    func updateLog(_ log: LogEntry) {
        saveActivityLog(log)
    }
    
    func deleteLog(_ log: LogEntry) {
        var logs = getAllActivityLogs()
        logs.removeAll { $0.id == log.id }
        
        if let encoded = try? JSONEncoder().encode(logs) {
            userDefaults.set(encoded, forKey: activityFeedKey)
            print("✅ Deleted activity log: \(log.id)")
        }
    }
    
    func clearAllLogs() {
        userDefaults.removeObject(forKey: activityFeedKey)
        print("✅ Cleared all activity logs")
    }
}
