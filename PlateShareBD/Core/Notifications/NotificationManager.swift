//
//  NotificationManager.swift
//  PlateShareBD
//
//  Created by PlateShare Team.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
            print("Notification permission granted: \(granted)")
        }
    }

    /// Schedule a local notification (e.g., for listing expiry reminders)
    func scheduleExpiryReminder(listingTitle: String, expiresAt: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Food Expiring Soon! ⏰"
        content.body = "\"\(listingTitle)\" is about to expire. Check if someone wants to pick it up!"
        content.sound = .default

        // Trigger 30 minutes before expiry
        let triggerDate = Calendar.current.date(byAdding: .minute, value: -30, to: expiresAt) ?? expiresAt
        let timeInterval = triggerDate.timeIntervalSinceNow
        guard timeInterval > 0 else { return }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}
