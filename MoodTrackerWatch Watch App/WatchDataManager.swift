//
//  WatchDataManager.swift
//  MoodTrackerWatch Watch App
//
//  Data manager for Watch app using shared App Group
//

import Foundation
import Combine

class WatchDataManager: ObservableObject {
    static let shared = WatchDataManager()

    @Published var todayEntries: [SharedMoodEntry] = []

    private let appGroupID = "group.com.aibymm.moodflex"
    private let entriesKey = "moodEntries"
    private let sharedDefaults: UserDefaults?

    init() {
        self.sharedDefaults = UserDefaults(suiteName: appGroupID)

        if sharedDefaults == nil {
            print("⚠️ WARNING: Could not initialize App Group UserDefaults!")
            print("⚠️ Make sure '\(appGroupID)' is enabled in App Groups capability")
        }

        loadEntries()
    }

    /// Load all mood entries from shared UserDefaults and filter today's entries
    func loadEntries() {
        print("📂 Watch: Loading entries from shared UserDefaults...")

        guard let sharedDefaults = sharedDefaults else {
            print("❌ Watch: Shared UserDefaults not available")
            todayEntries = []
            return
        }

        guard let data = sharedDefaults.data(forKey: entriesKey) else {
            print("⚠️ Watch: No data found in shared UserDefaults")
            todayEntries = []
            return
        }

        do {
            let decoder = JSONDecoder()
            let allEntries = try decoder.decode([SharedMoodEntry].self, from: data)

            // Filter today's entries
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            todayEntries = allEntries
                .filter { calendar.isDate($0.date, inSameDayAs: today) }
                .sorted { $0.date > $1.date } // Most recent first

            print("✅ Watch: Successfully loaded \(allEntries.count) total entries")
            print("✅ Watch: Found \(todayEntries.count) entries for today")
        } catch {
            print("❌ Watch: Error loading entries: \(error)")
            todayEntries = []
        }
    }

    /// Add a new mood entry from Watch
    func addEntry(mood: MoodType) {
        print("➕ Watch: Adding new entry: \(mood.name)")

        guard let sharedDefaults = sharedDefaults else {
            print("❌ Watch: Cannot save: Shared UserDefaults not available")
            return
        }

        // Load existing entries
        var allEntries: [SharedMoodEntry] = []
        if let data = sharedDefaults.data(forKey: entriesKey) {
            do {
                let decoder = JSONDecoder()
                allEntries = try decoder.decode([SharedMoodEntry].self, from: data)
            } catch {
                print("⚠️ Watch: Could not load existing entries: \(error)")
            }
        }

        // Create new entry
        let newEntry = SharedMoodEntry(
            id: UUID(),
            date: Date(),
            mood: mood,
            note: "Logged from Apple Watch"
        )

        // Add to beginning (newest first)
        allEntries.insert(newEntry, at: 0)

        // Save back to shared UserDefaults
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(allEntries)
            sharedDefaults.set(data, forKey: entriesKey)

            // Force synchronize
            let success = sharedDefaults.synchronize()

            if success {
                print("✅ Watch: Successfully saved entry")

                // Update today's entries
                loadEntries()

                // Notify iPhone to reload if needed (via Watch Connectivity if implemented)
                print("📱 Watch: Notifying iPhone to reload data...")
            } else {
                print("⚠️ Watch: synchronize() returned false")
            }
        } catch {
            print("❌ Watch: Error saving entry: \(error)")
        }
    }
}
