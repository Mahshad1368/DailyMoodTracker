//
//  MoodEntry.swift
//  DailyMoodTracker
//
//  Represents a single mood entry with date, mood type, optional note, photo, and voice recording
//

import Foundation

struct MoodEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let mood: MoodType
    let note: String
    let photoData: Data?  // Store image as Data
    let audioData: Data?  // Store audio as Data
    let audioDuration: TimeInterval?  // Duration in seconds

    init(id: UUID = UUID(), date: Date = Date(), mood: MoodType, note: String = "", photoData: Data? = nil, audioData: Data? = nil, audioDuration: TimeInterval? = nil) {
        self.id = id
        self.date = date
        self.mood = mood
        self.note = note
        self.photoData = photoData
        self.audioData = audioData
        self.audioDuration = audioDuration
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

    /// Check if entry has attachments
    var hasAttachments: Bool {
        photoData != nil || audioData != nil
    }
}
