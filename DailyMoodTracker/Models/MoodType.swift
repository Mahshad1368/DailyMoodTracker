//
//  MoodType.swift
//  DailyMoodTracker
//
//  Defines the available mood types with their emoji representations
//

import Foundation
import SwiftUI

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
}
