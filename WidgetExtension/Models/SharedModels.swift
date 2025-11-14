//
//  SharedModels.swift
//  Shared between Main App and Widget Extension
//
//  Data models that can be used by both the main app and widget
//

import Foundation
import SwiftUI

// MARK: - Shared Mood Type
enum MoodType: String, Codable, CaseIterable {
    case happy = "happy"
    case neutral = "neutral"
    case sad = "sad"
    case angry = "angry"
    case sleepy = "sleepy"

    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .neutral: return "😐"
        case .sad: return "😔"
        case .angry: return "😡"
        case .sleepy: return "😴"
        }
    }

    var name: String {
        switch self {
        case .happy: return "Happy"
        case .neutral: return "Neutral"
        case .sad: return "Sad"
        case .angry: return "Angry"
        case .sleepy: return "Sleepy"
        }
    }

    var color: Color {
        switch self {
        case .happy: return .green
        case .neutral: return .blue
        case .sad: return .indigo
        case .angry: return .red
        case .sleepy: return .purple
        }
    }

    // Image name for Assets.xcassets
    var imageName: String {
        switch self {
        case .happy: return "HappyEmoji"
        case .neutral: return "NeutralEmoji"
        case .sad: return "SadEmoji"
        case .angry: return "AngryEmoji"
        case .sleepy: return "SleepyEmoji"
        }
    }

    // Widget gradient colors
    var widgetGradient: [Color] {
        switch self {
        case .happy:
            return [Color(hex: "FFD93D"), Color(hex: "FFAA80")]
        case .neutral:
            return [Color(hex: "A8D8EA"), Color(hex: "6BA3BE")]
        case .sad:
            return [Color(hex: "C8B6E2"), Color(hex: "9B7EBD")]
        case .angry:
            return [Color(hex: "FF6B6B"), Color(hex: "E63946")]
        case .sleepy:
            return [Color(hex: "F4E4C1"), Color(hex: "C9C9C9")]
        }
    }
}

// MARK: - Shared Mood Entry
struct SharedMoodEntry: Identifiable, Codable {
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

    /// Returns the time formatted as a string (e.g., "10:00 AM")
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Returns the date formatted as a string (e.g., "Jan 15, 2025")
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
