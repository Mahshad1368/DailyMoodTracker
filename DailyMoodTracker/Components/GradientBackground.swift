//
//  GradientBackground.swift
//  DailyMoodTracker
//
//  Time-based gradient backgrounds that change throughout the day
//

import SwiftUI

struct GradientBackground: View {
    var timeOfDay: Date.TimeOfDay

    var body: some View {
        gradient
            .ignoresSafeArea()
    }

    private var gradient: LinearGradient {
        switch timeOfDay {
        case .morning:
            return LinearGradient(
                colors: [Color(hex: "FFB3BA"), Color(hex: "FFDFBA")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .afternoon:
            return LinearGradient(
                colors: [Color(hex: "FFDFBA"), Color(hex: "FFFFBA")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .evening:
            return LinearGradient(
                colors: [Color(hex: "E0BBE4"), Color(hex: "FFB3BA")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .night:
            return LinearGradient(
                colors: [Color(hex: "957DAD"), Color(hex: "7D5BA6")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Dark Gradient Background
struct DarkGradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "2C2C2C"),
                Color(hex: "1A1A2E"),
                Color(hex: "16213E")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Onboarding Gradient Backgrounds
struct OnboardingGradient: View {
    let type: GradientType

    enum GradientType {
        case welcome    // Pink to yellow
        case awareness  // Blue gradient
        case patterns   // Purple gradient
    }

    var body: some View {
        gradient
            .ignoresSafeArea()
    }

    private var gradient: LinearGradient {
        switch type {
        case .welcome:
            return LinearGradient(
                colors: [Color(hex: "FF9A9E"), Color(hex: "FAD0C4"), Color(hex: "FFEAA7")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .awareness:
            return LinearGradient(
                colors: [Color(hex: "667EEA"), Color(hex: "764BA2"), Color(hex: "5F72BD")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .patterns:
            return LinearGradient(
                colors: [Color(hex: "A8EDEA"), Color(hex: "667EEA"), Color(hex: "764BA2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

#Preview("Morning") {
    GradientBackground(timeOfDay: .morning)
}

#Preview("Afternoon") {
    GradientBackground(timeOfDay: .afternoon)
}

#Preview("Evening") {
    GradientBackground(timeOfDay: .evening)
}

#Preview("Night") {
    GradientBackground(timeOfDay: .night)
}

#Preview("Dark") {
    DarkGradientBackground()
}
