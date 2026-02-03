//
//  NotificationManager.swift
//  ParentBud_01
//
//  Created by Aayush Kumar on 16/11/25.
//


//
//  NotificationManager.swift
//  ParentBud_01
//
//  Created by GlitchZap on 2025-11-16
//

import UIKit
import UserNotifications

class NotificationManager: NSObject {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
    }
    
    // MARK: - Request Permission
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Notification permission granted")
                    UIApplication.shared.registerForRemoteNotifications()
                } else {
                    print("❌ Notification permission denied")
                }
            }
        }
    }
    
    // MARK: - Send Local Notification for Expert Message
    func sendExpertMessageNotification(expertName: String, message: String, expertId: String) {
        let content = UNMutableNotificationContent()
        content.title = expertName
        content.body = message
        content.sound = .default
        content.badge = 1
        
        // Add custom user info for handling tap
        content.userInfo = [
            "type": "expert_message",
            "expertId": expertId,
            "expertName": expertName
        ]
        
        // Create trigger (immediate delivery)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "expert_message_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        // Add notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send notification: \(error)")
            } else {
                print("✅ Expert message notification sent")
            }
        }
    }
    
    // MARK: - Send Session Reminder
    func sendSessionReminderNotification(expertName: String, sessionDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Session Reminder"
        content.body = "Your session with \(expertName) starts in 15 minutes"
        content.sound = .default
        content.badge = 1
        
        // Schedule 15 minutes before session
        let reminderDate = sessionDate.addingTimeInterval(-15 * 60)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "session_reminder_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule session reminder: \(error)")
            } else {
                print("✅ Session reminder scheduled")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Show notification even when app is active
        completionHandler([.alert, .badge, .sound])
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let type = userInfo["type"] as? String, type == "expert_message" {
            // Navigate to expert chat
            navigateToExpertChat(userInfo: userInfo)
        }
        
        completionHandler()
    }
    
    private func navigateToExpertChat(userInfo: [AnyHashable: Any]) {
        // Post notification to handle navigation in the app
        NotificationCenter.default.post(
            name: NSNotification.Name("NavigateToExpertChat"),
            object: nil,
            userInfo: userInfo
        )
    }
}