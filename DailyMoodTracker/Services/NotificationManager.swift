//
//  NotificationManager.swift
//  DailyMoodTracker
//
//  Handles notification categories, actions, and delegate callbacks
//  Enables actionable notifications on iPhone and Apple Watch
//

import Foundation
import UserNotifications

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    // Reference to DataManager for saving mood entries from notifications
    private var dataManager: DataManager?

    // Notification identifiers
    static let dailyReminderIdentifier = "dailyMoodReminder"
    static let categoryIdentifier = "MOOD_REMINDER"

    // Action identifiers for each mood type
    private enum ActionIdentifier: String {
        case logHappy = "LOG_HAPPY"
        case logNeutral = "LOG_NEUTRAL"
        case logSad = "LOG_SAD"
        case logAngry = "LOG_ANGRY"
        case logSleepy = "LOG_SLEEPY"

        var moodType: MoodType {
            switch self {
            case .logHappy: return .happy
            case .logNeutral: return .neutral
            case .logSad: return .sad
            case .logAngry: return .angry
            case .logSleepy: return .sleepy
            }
        }
    }

    override init() {
        super.init()
        registerNotificationCategories()
    }

    /// Set the DataManager reference for saving mood entries
    func setDataManager(_ manager: DataManager) {
        self.dataManager = manager
    }

    /// Register notification categories with action buttons
    private func registerNotificationCategories() {
        // Create actions for each mood type
        // Note: Using empty options [] allows actions to work on Apple Watch
        // .foreground would require opening the app, which doesn't work well on Watch
        let happyAction = UNNotificationAction(
            identifier: ActionIdentifier.logHappy.rawValue,
            title: "😊 Happy",
            options: []
        )

        let neutralAction = UNNotificationAction(
            identifier: ActionIdentifier.logNeutral.rawValue,
            title: "😐 Neutral",
            options: []
        )

        let sadAction = UNNotificationAction(
            identifier: ActionIdentifier.logSad.rawValue,
            title: "😢 Sad",
            options: []
        )

        let angryAction = UNNotificationAction(
            identifier: ActionIdentifier.logAngry.rawValue,
            title: "😠 Angry",
            options: []
        )

        let sleepyAction = UNNotificationAction(
            identifier: ActionIdentifier.logSleepy.rawValue,
            title: "😴 Sleepy",
            options: []
        )

        // Create category with all mood actions
        let moodCategory = UNNotificationCategory(
            identifier: Self.categoryIdentifier,
            actions: [happyAction, neutralAction, sadAction, angryAction, sleepyAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        // Register the category
        UNUserNotificationCenter.current().setNotificationCategories([moodCategory])

        print("✅ Registered notification category with \(5) mood actions")
    }

    /// Schedule daily reminder notification with actionable buttons
    func scheduleDailyReminder(at time: Date) {
        // Remove existing notifications first
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [Self.dailyReminderIdentifier]
        )

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "How are you feeling?"
        content.body = "Take a moment to log your mood"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = Self.categoryIdentifier // Enable action buttons

        // Create trigger from the provided time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        // Create request
        let request = UNNotificationRequest(
            identifier: Self.dailyReminderIdentifier,
            content: content,
            trigger: trigger
        )

        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("✅ Daily reminder scheduled with actionable buttons")
                if let hour = components.hour, let minute = components.minute {
                    print("   Time: \(String(format: "%02d:%02d", hour, minute))")
                }
            }
        }
    }

    /// Cancel daily reminder
    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [Self.dailyReminderIdentifier]
        )
        print("✅ Daily reminder cancelled")
    }

    /// Send a test notification immediately (5 seconds delay)
    func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test: How are you feeling?"
        content.body = "Tap a mood button to test the feature"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = Self.categoryIdentifier // Enable action buttons

        // Trigger in 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(
            identifier: "testNotification",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error sending test notification: \(error.localizedDescription)")
            } else {
                print("✅ Test notification will appear in 5 seconds")
                print("   Check your Apple Watch and iPhone")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {

    /// Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    /// Handle notification tap or action button tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier

        print("📲 Notification action received: \(actionIdentifier)")

        // Check if it's a mood action (not default tap)
        if actionIdentifier != UNNotificationDefaultActionIdentifier,
           actionIdentifier != UNNotificationDismissActionIdentifier {

            // Try to convert action identifier to ActionIdentifier enum
            if let action = ActionIdentifier(rawValue: actionIdentifier) {
                let mood = action.moodType

                print("✅ Logging mood from notification: \(mood.name)")

                // Save the mood entry
                dataManager?.addEntry(mood: mood, note: "Logged from notification")

                // Clear the badge
                center.setBadgeCount(0) { _ in }

                print("✅ Mood logged successfully from notification action")
            }
        } else if actionIdentifier == UNNotificationDefaultActionIdentifier {
            // User tapped the notification itself (not an action button)
            print("ℹ️ User tapped notification (opening app)")
        }

        completionHandler()
    }
}
