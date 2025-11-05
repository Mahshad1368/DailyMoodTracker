//
//  IconManager.swift
//  DailyMoodTracker
//
//  Manages dynamic app icon changes based on daily mood
//

import UIKit

class IconManager {
    static let shared = IconManager()

    private init() {}

    /// Icon names corresponding to each mood type
    enum AppIcon: String {
        case defaultIcon = "AppIcon"  // Default happy icon
        case happy = "AppIcon-Happy"
        case neutral = "AppIcon-Neutral"
        case sad = "AppIcon-Sad"
        case angry = "AppIcon-Angry"
        case sleepy = "AppIcon-Sleepy"

        /// Get icon name for a mood type
        static func forMood(_ mood: MoodType) -> AppIcon {
            switch mood {
            case .happy: return .happy
            case .neutral: return .neutral
            case .sad: return .sad
            case .angry: return .angry
            case .sleepy: return .sleepy
            }
        }
    }

    /// Update app icon based on dominant mood for today
    func updateIconForDominantMood(entries: [MoodEntry]) {
        print("🎨 Updating app icon based on mood...")

        // Filter today's entries
        let todayEntries = entries.filter {
            Calendar.current.isDate($0.date, inSameDayAs: Date())
        }

        guard !todayEntries.isEmpty else {
            print("ℹ️ No moods logged today, keeping current icon")
            return
        }

        // Count mood occurrences
        var moodCounts: [MoodType: Int] = [:]
        for entry in todayEntries {
            moodCounts[entry.mood, default: 0] += 1
        }

        // Find dominant mood
        guard let dominantMood = moodCounts.max(by: { $0.value < $1.value })?.key else {
            print("⚠️ Could not determine dominant mood")
            return
        }

        print("📊 Dominant mood today: \(dominantMood.name) (\(moodCounts[dominantMood] ?? 0) entries)")

        // Get icon for dominant mood
        let targetIcon = AppIcon.forMood(dominantMood)
        setIcon(targetIcon)
    }

    /// Set app icon to specific variant
    func setIcon(_ icon: AppIcon) {
        guard UIApplication.shared.supportsAlternateIcons else {
            print("⚠️ Alternate icons not supported on this device")
            return
        }

        // Get current icon name
        let currentIconName = UIApplication.shared.alternateIconName
        let targetIconName = icon == .defaultIcon ? nil : icon.rawValue

        // Check if already set to target icon
        if currentIconName == targetIconName {
            print("✅ Icon already set to \(icon.rawValue)")
            return
        }

        print("🔄 Changing icon to \(icon.rawValue)...")

        UIApplication.shared.setAlternateIconName(targetIconName) { error in
            if let error = error {
                print("❌ Error changing icon: \(error.localizedDescription)")
            } else {
                print("✅ Successfully changed icon to \(icon.rawValue)")
            }
        }
    }

    /// Reset to default icon
    func resetToDefaultIcon() {
        setIcon(.defaultIcon)
    }

    /// Get current icon name
    var currentIconName: String {
        return UIApplication.shared.alternateIconName ?? "AppIcon (Default)"
    }
}
