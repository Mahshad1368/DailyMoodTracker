//
//  DarkThemeCard.swift
//  DailyMoodTracker
//
//  Frosted glass card component for dark theme
//

import SwiftUI

/// Frosted glass card with dark theme styling
struct DarkThemeCard<Content: View>: View {
    let padding: CGFloat
    let content: Content

    init(padding: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial.opacity(0.8))
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.3))
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 4)
            )
    }
}

/// Dark theme gradient background
struct DarkThemeBackground: View {
    var body: some View {
        Color.darkTheme.backgroundGradient
            .ignoresSafeArea()
    }
}

/// Frosted glass card with less opacity for nested content
struct DarkThemeNestedCard<Content: View>: View {
    let padding: CGFloat
    let content: Content

    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
    }
}

#Preview {
    ZStack {
        DarkThemeBackground()

        VStack(spacing: 20) {
            DarkThemeCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Dark Theme Card")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Color.darkTheme.textPrimary)

                    Text("This is a frosted glass card with the dark theme styling.")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(Color.darkTheme.textSecondary)

                    DarkThemeNestedCard {
                        Text("Nested Card")
                            .foregroundColor(Color.darkTheme.textPrimary)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
