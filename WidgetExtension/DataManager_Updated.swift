//
//  DataManager_Updated.swift
//  DailyMoodTracker
//
//  ⚠️ REPLACE YOUR EXISTING DataManager.swift WITH THIS FILE
//
//  Updated DataManager that uses App Groups to share data with widgets
//  Handles data persistence using shared UserDefaults
//  Supports multiple mood entries per day
//

import Foundation
import WidgetKit

// MARK: - App Group Configuration
private let appGroupID = "group.com.dailymoodtracker.app"

class DataManager: ObservableObject {
    private let entriesKey = "moodEntries"
    @Published var entries: [MoodEntry] = []

    // Use shared UserDefaults for App Group
    private let sharedDefaults: UserDefaults?

    init() {
        // Initialize with App Group UserDefaults
        self.sharedDefaults = UserDefaults(suiteName: appGroupID)

        if sharedDefaults == nil {
            print("⚠️ WARNING: Could not initialize App Group UserDefaults!")
            print("⚠️ Make sure '\(appGroupID)' is enabled in App Groups capability")
        }

        loadEntries()
        print("📊 DataManager initialized with \(entries.count) entries")
    }

    /// Load all mood entries from shared UserDefaults
    func loadEntries() {
        print("📂 Loading entries from shared UserDefaults...")

        guard let sharedDefaults = sharedDefaults else {
            print("❌ Shared UserDefaults not available")
            entries = []
            return
        }

        guard let data = sharedDefaults.data(forKey: entriesKey) else {
            print("⚠️ No data found in shared UserDefaults")

            // Try to migrate from old UserDefaults if exists
            migrateFromOldUserDefaults()
            return
        }

        print("📦 Found data: \(data.count) bytes")

        do {
            let decoder = JSONDecoder()
            entries = try decoder.decode([MoodEntry].self, from: data)
            // Sort by date, newest first
            entries.sort { $0.date > $1.date }
            print("✅ Successfully loaded \(entries.count) entries")

            // Debug: Print loaded entries
            for (index, entry) in entries.prefix(3).enumerated() {
                print("  Entry \(index + 1): \(entry.mood.name) at \(entry.formattedTime)")
            }
        } catch {
            print("❌ Error loading entries: \(error)")
            print("🧹 Clearing corrupted data from shared UserDefaults...")

            // Clear the corrupted data to start fresh
            sharedDefaults.removeObject(forKey: entriesKey)
            sharedDefaults.synchronize()

            entries = []
            print("✅ Shared UserDefaults cleared. Ready for fresh data.")
        }
    }

    /// Migrate data from old UserDefaults to App Group UserDefaults
    private func migrateFromOldUserDefaults() {
        print("🔄 Attempting to migrate data from old UserDefaults...")

        guard let oldData = UserDefaults.standard.data(forKey: entriesKey) else {
            print("ℹ️ No old data to migrate")
            entries = []
            return
        }

        print("📦 Found old data: \(oldData.count) bytes - migrating...")

        do {
            let decoder = JSONDecoder()
            let oldEntries = try decoder.decode([MoodEntry].self, from: oldData)

            // Save to new shared UserDefaults
            entries = oldEntries
            saveEntries()

            print("✅ Successfully migrated \(entries.count) entries to App Group")
            print("🧹 Cleaning up old UserDefaults...")

            // Optional: Remove from old UserDefaults after successful migration
            // UserDefaults.standard.removeObject(forKey: entriesKey)
            // UserDefaults.standard.synchronize()
        } catch {
            print("❌ Error migrating data: \(error)")
            entries = []
        }
    }

    /// Save all mood entries to shared UserDefaults and update widgets
    private func saveEntries() {
        guard let sharedDefaults = sharedDefaults else {
            print("❌ Cannot save: Shared UserDefaults not available")
            return
        }

        print("💾 Saving \(entries.count) entries to shared UserDefaults...")

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(entries)
            sharedDefaults.set(data, forKey: entriesKey)

            // Force synchronize to ensure data is written immediately
            let success = sharedDefaults.synchronize()

            if success {
                print("✅ Successfully saved \(entries.count) entries (\(data.count) bytes)")

                // Immediate verification - read back to confirm
                if let verifyData = sharedDefaults.data(forKey: entriesKey) {
                    print("🔍 Verification: Data found in shared UserDefaults (\(verifyData.count) bytes)")

                    do {
                        let decoder = JSONDecoder()
                        let verifyEntries = try decoder.decode([MoodEntry].self, from: verifyData)
                        print("✅ Verification: Successfully decoded \(verifyEntries.count) entries")
                    } catch {
                        print("❌ Verification failed: \(error)")
                    }
                } else {
                    print("❌ Verification failed: No data found after save!")
                }

                // CRITICAL: Reload all widget timelines after saving
                print("🔄 Reloading all widget timelines...")
                WidgetCenter.shared.reloadAllTimelines()
                print("✅ Widget timelines reloaded")
            } else {
                print("⚠️ synchronize() returned false")
            }
        } catch {
            print("❌ Error saving entries: \(error)")
        }
    }

    /// Add a new mood entry (allows multiple entries per day)
    func addEntry(mood: MoodType, note: String) {
        let newEntry = MoodEntry(mood: mood, note: note)
        entries.insert(newEntry, at: 0) // Add to beginning (newest first)
        saveEntries()

        print("➕ Added new entry: \(mood.name)")

        // Update app icon based on dominant mood
        IconManager.shared.updateIconForDominantMood(entries: entries)
    }

    /// Get all entries for today
    func getEntriesToday() -> [MoodEntry] {
        let today = Calendar.current.startOfDay(for: Date())
        return entries.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .sorted { $0.date > $1.date } // Most recent first
    }

    /// Get all entries for a specific date
    func getEntries(for date: Date) -> [MoodEntry] {
        return entries.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date > $1.date } // Most recent first
    }

    /// Check if any entries exist for today
    func hasEntriesToday() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return entries.contains { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    /// Delete an entry
    func deleteEntry(_ entry: MoodEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()

        print("🗑️ Deleted entry: \(entry.mood.name)")

        // Update app icon based on remaining moods
        IconManager.shared.updateIconForDominantMood(entries: entries)
    }
}

// MARK: - App Group Helper
extension DataManager {
    /// Check if App Group is properly configured
    func verifyAppGroupConfiguration() -> Bool {
        guard let sharedDefaults = sharedDefaults else {
            print("❌ App Group verification failed: UserDefaults(suiteName:) returned nil")
            return false
        }

        // Try to write and read a test value
        let testKey = "appGroupTest"
        let testValue = "configured"

        sharedDefaults.set(testValue, forKey: testKey)
        sharedDefaults.synchronize()

        if let readValue = sharedDefaults.string(forKey: testKey), readValue == testValue {
            print("✅ App Group is properly configured")
            sharedDefaults.removeObject(forKey: testKey)
            return true
        } else {
            print("❌ App Group verification failed: Could not read written test value")
            return false
        }
    }
}
