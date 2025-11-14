//
//  Extensions.swift
//  DailyMoodTracker
//
//  Utility extensions for Color, View, and Date
//

import SwiftUI

// MARK: - Color Extension for Hex Support
extension Color {
    /// Initialize Color from hex string (e.g., "FFB3BA" or "#FFB3BA")
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

    // MARK: - Dark Theme Colors
    static let darkTheme = DarkThemeColors()

    struct DarkThemeColors {
        // Background gradients
        let bgDark = Color(hex: "3D2C2E")           // Dark brown
        let bgDarker = Color(hex: "2A1F20")         // Darker brown

        // Text colors
        let textPrimary = Color(hex: "F5E6D3")      // Cream/beige
        let textSecondary = Color(hex: "D4B5A0")    // Light brown

        // Accent colors
        let accent = Color(hex: "8B6E9F")           // Purple highlight
        let accentLight = Color(hex: "A88BB8")      // Lighter purple

        // Card backgrounds
        let cardBg = Color.black.opacity(0.3)       // Semi-transparent dark

        // Create gradient
        var backgroundGradient: LinearGradient {
            LinearGradient(
                colors: [bgDark, bgDarker],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    // MARK: - Light Theme Colors
    static let lightTheme = LightThemeColors()

    struct LightThemeColors {
        // Background gradients
        let bgLight = Color(hex: "F5F0E8")          // Soft cream
        let bgLighter = Color(hex: "FFFFFF")        // White

        // Text colors
        let textPrimary = Color(hex: "2A1F20")      // Dark brown
        let textSecondary = Color(hex: "6B5B5C")    // Medium brown

        // Accent colors
        let accent = Color(hex: "8B6E9F")           // Purple highlight (same as dark)
        let accentLight = Color(hex: "A88BB8")      // Lighter purple

        // Card backgrounds
        let cardBg = Color.white.opacity(0.8)       // Semi-transparent white

        // Create gradient
        var backgroundGradient: LinearGradient {
            LinearGradient(
                colors: [bgLight, bgLighter],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    // MARK: - Dynamic Theme (switches based on setting)
    static func appTheme(isDark: Bool) -> ThemeColors {
        return isDark ? DarkThemeColors() : LightThemeColors()
    }
}

// MARK: - Theme Colors Protocol
protocol ThemeColors {
    var backgroundGradient: LinearGradient { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var accent: Color { get }
    var accentLight: Color { get }
    var cardBg: Color { get }
}

extension Color.DarkThemeColors: ThemeColors {}
extension Color.LightThemeColors: ThemeColors {}

// MARK: - View Extension for Glassmorphism Effect
extension View {
    /// Apply glassmorphism effect with frosted glass appearance
    func glassEffect() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
    }

    /// Apply glassmorphism with custom corner radius
    func glassEffect(cornerRadius: CGFloat) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
    }

    /// Apply dark glassmorphism effect
    func darkGlassEffect() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.thinMaterial)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
    }
}

// MARK: - Date Extension for Time of Day
extension Date {
    /// Returns the time period of the day
    enum TimeOfDay {
        case morning    // 6am - 12pm
        case afternoon  // 12pm - 6pm
        case evening    // 6pm - 10pm
        case night      // 10pm - 6am

        var emoji: String {
            switch self {
            case .morning: return "🌅"
            case .afternoon: return "☀️"
            case .evening: return "🌙"
            case .night: return "🌙"
            }
        }
    }

    /// Get the current time of day
    var timeOfDay: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: self)
        switch hour {
        case 6..<12: return .morning
        case 12..<18: return .afternoon
        case 18..<22: return .evening
        default: return .night
        }
    }

    /// Get a personalized greeting based on time of day
    var greeting: String {
        switch timeOfDay {
        case .morning: return "Good morning"
        case .afternoon: return "Good afternoon"
        case .evening: return "Good evening"
        case .night: return "Good night"
        }
    }

    /// Returns formatted date string like "Tuesday, 28 May"
    var friendlyDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: self)
    }
}

// MARK: - MoodType Extension for Gradients
extension MoodType {
    /// Gradient colors for each mood
    var gradientColors: [Color] {
        switch self {
        case .happy:
            return [Color(hex: "FFD93D"), Color(hex: "FFA500")]
        case .neutral:
            return [Color(hex: "4ECDC4"), Color(hex: "44A08D")]
        case .sad:
            return [Color(hex: "667EEA"), Color(hex: "764BA2")]
        case .angry:
            return [Color(hex: "FF6B9D"), Color(hex: "C06C84")]
        case .sleepy:
            return [Color(hex: "A8EDEA"), Color(hex: "7F7FD5")]
        }
    }

    /// Linear gradient for mood
    var gradient: LinearGradient {
        LinearGradient(
            colors: gradientColors,
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
