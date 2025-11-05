//
//  DataManager.swift
//  DailyMoodTracker
//
//  Handles data persistence using UserDefaults
//  Supports multiple mood entries per day
//

import Foundation

class DataManager: ObservableObject {
    private let entriesKey = "moodEntries"
    @Published var entries: [MoodEntry] = []

    init() {
        loadEntries()
        print("📊 DataManager initialized with \(entries.count) entries")
    }

    /// Load all mood entries from UserDefaults
    func loadEntries() {
        print("📂 Loading entries from UserDefaults...")

        guard let data = UserDefaults.standard.data(forKey: entriesKey) else {
            print("⚠️ No data found in UserDefaults")
            entries = []
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
            print("🧹 Clearing corrupted data from UserDefaults...")

            // Clear the corrupted data to start fresh
            UserDefaults.standard.removeObject(forKey: entriesKey)
            UserDefaults.standard.synchronize()

            entries = []
            print("✅ UserDefaults cleared. Ready for fresh data.")
        }
    }

    /// Save all mood entries to UserDefaults
    private func saveEntries() {
        print("💾 Saving \(entries.count) entries to UserDefaults...")

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(entries)
            UserDefaults.standard.set(data, forKey: entriesKey)

            // Force synchronize to ensure data is written immediately
            let success = UserDefaults.standard.synchronize()

            if success {
                print("✅ Successfully saved \(entries.count) entries (\(data.count) bytes)")

                // Immediate verification - read back to confirm
                if let verifyData = UserDefaults.standard.data(forKey: entriesKey) {
                    print("🔍 Verification: Data found in UserDefaults (\(verifyData.count) bytes)")

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

        // Update app icon based on remaining moods
        IconManager.shared.updateIconForDominantMood(entries: entries)
    }
}
