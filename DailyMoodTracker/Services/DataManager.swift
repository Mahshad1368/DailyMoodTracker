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

        // Try to load from full data storage (includes photo/audio)
        if let fullData = sharedDefaults.data(forKey: "fullMoodEntries") {
            print("📦 Found full data: \(fullData.count) bytes")

            do {
                let decoder = JSONDecoder()
                entries = try decoder.decode([MoodEntry].self, from: fullData)
                // Sort by date, newest first
                entries.sort { $0.date > $1.date }
                print("✅ Successfully loaded \(entries.count) full entries")

                // Debug: Print loaded entries
                for (index, entry) in entries.prefix(3).enumerated() {
                    print("  Entry \(index + 1): \(entry.mood.name) at \(entry.formattedTime)")
                }
                return
            } catch {
                print("❌ Error loading full entries: \(error)")
            }
        }

        // Fallback: Try to load from old location or migrate
        print("⚠️ No full data found, checking for legacy data...")
        migrateFromOldUserDefaults()
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

            // Save full entries to main app storage (for photo/audio data)
            let fullData = try encoder.encode(entries)
            sharedDefaults.set(fullData, forKey: "fullMoodEntries")

            // Convert to SharedMoodEntry format for widget (without photo/audio)
            let sharedEntries = entries.map { entry in
                SharedMoodEntry(
                    id: entry.id,
                    date: entry.date,
                    mood: entry.mood,
                    note: entry.note
                )
            }

            // Save widget-compatible data
            let widgetData = try encoder.encode(sharedEntries)
            sharedDefaults.set(widgetData, forKey: entriesKey)

            // Force synchronize to ensure data is written immediately
            let success = sharedDefaults.synchronize()

            if success {
                print("✅ Successfully saved \(entries.count) entries")
                print("  - Full data: \(fullData.count) bytes")
                print("  - Widget data: \(widgetData.count) bytes")

                // Immediate verification - read back to confirm
                if let verifyData = sharedDefaults.data(forKey: entriesKey) {
                    print("🔍 Verification: Widget data found (\(verifyData.count) bytes)")

                    do {
                        let decoder = JSONDecoder()
                        let verifyEntries = try decoder.decode([SharedMoodEntry].self, from: verifyData)
                        print("✅ Verification: Successfully decoded \(verifyEntries.count) shared entries")
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
    func addEntry(mood: MoodType, note: String, photoData: Data? = nil, audioData: Data? = nil, audioDuration: TimeInterval? = nil) {
        let newEntry = MoodEntry(mood: mood, note: note, photoData: photoData, audioData: audioData, audioDuration: audioDuration)
        entries.insert(newEntry, at: 0) // Add to beginning (newest first)
        saveEntries()

        print("➕ Added new entry: \(mood.name)")
        if let photoData = photoData {
            print("📷 Entry includes photo (\(photoData.count) bytes)")
        }
        if let audioData = audioData {
            print("🎤 Entry includes audio (\(audioData.count) bytes, \(audioDuration ?? 0)s)")
        }
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
