//
//  MoodEntry.swift
//  DailyMoodTracker
//
//  Represents a single mood entry with date, mood type, and optional note
//

import Foundation

struct MoodEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let mood: MoodType
    let note: String

    init(id: UUID = UUID(), date: Date = Date(), mood: MoodType, note: String = "") {
        self.id = id
        self.date = date
        self.mood = mood
        self.note = note
    }

    /// Returns the date formatted as a string (e.g., "Jan 15, 2025")
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// Returns the time formatted as a string (e.g., "10:00 AM")
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Returns date and time formatted (e.g., "Jan 15, 10:00 AM")
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Returns just the date portion (without time) for comparison
    var dateOnly: Date {
        Calendar.current.startOfDay(for: date)
    }
}
