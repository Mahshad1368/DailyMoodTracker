//
//  DarkThemeCard.swift
//  DailyMoodTracker
//
//  Frosted glass card component supporting both light and dark themes
//

import SwiftUI

/// Frosted glass card with theme-aware styling
struct DarkThemeCard<Content: View>: View {
    let padding: CGFloat
    let content: Content
    let isDark: Bool
    let cornerRadius: CGFloat

    init(padding: CGFloat = 20, isDark: Bool = true, cornerRadius: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.isDark = isDark
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial.opacity(0.8))
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(isDark ? Color.black.opacity(0.3) : Color.white.opacity(0.5))
                    )
                    .shadow(color: isDark ? .black.opacity(0.3) : .gray.opacity(0.2), radius: 20, x: 0, y: 4)
            )
    }
}

/// Theme-aware gradient background
struct DarkThemeBackground: View {
    let isDark: Bool

    init(isDark: Bool = true) {
        self.isDark = isDark
    }

    var body: some View {
        (isDark ? Color.darkTheme.backgroundGradient : Color.lightTheme.backgroundGradient)
            .ignoresSafeArea()
    }
}

/// Frosted glass card with less opacity for nested content
struct DarkThemeNestedCard<Content: View>: View {
    let padding: CGFloat
    let content: Content
    let isDark: Bool

    init(padding: CGFloat = 16, isDark: Bool = true, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.isDark = isDark
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isDark ? Color.black.opacity(0.2) : Color.white.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isDark ? Color.white.opacity(0.1) : Color.gray.opacity(0.2), lineWidth: 1)
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
