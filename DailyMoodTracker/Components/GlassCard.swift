//
//  GlassCard.swift
//  DailyMoodTracker
//
//  Reusable glassmorphism card component
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 20

    init(
        cornerRadius: CGFloat = 20,
        padding: CGFloat = 20,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
    }
}

// MARK: - Dark Glass Card
struct DarkGlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 20

    init(
        cornerRadius: CGFloat = 20,
        padding: CGFloat = 20,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.thinMaterial)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
    }
}

#Preview {
    ZStack {
        GradientBackground(timeOfDay: .morning)

        VStack(spacing: 20) {
            GlassCard {
                VStack(spacing: 10) {
                    Text("Glassmorphism Card")
                        .font(.headline)
                    Text("This is a frosted glass effect card with a semi-transparent background.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()

            DarkGlassCard {
                VStack(spacing: 10) {
                    Text("Dark Glass Card")
                        .font(.headline)
                    Text("This is a darker variant for dark backgrounds.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
}
