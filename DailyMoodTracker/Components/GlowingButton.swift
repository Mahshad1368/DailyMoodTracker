//
//  GlowingButton.swift
//  DailyMoodTracker
//
//  Animated button with gradient and glow effect
//

import SwiftUI

struct GlowingButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var colors: [Color] = [Color(hex: "FFD93D"), Color(hex: "FFA500")]

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            if isEnabled {
                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                action()
            }
        }) {
            Text(title)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: isEnabled ? colors : [Color.gray, Color.gray.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(
                    color: isEnabled ? colors.first!.opacity(0.4) : Color.clear,
                    radius: 15,
                    x: 0,
                    y: 8
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .disabled(!isEnabled)
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

// MARK: - Mood Button Component (Enhanced)
struct EnhancedMoodButton: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void

    @State private var isPulsing = false

    var body: some View {
        Button(action: {
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            VStack(spacing: 8) {
                Text(mood.emoji)
                    .font(.system(size: 60))
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                    .shadow(
                        color: isSelected ? mood.color.opacity(0.5) : .clear,
                        radius: isPulsing && isSelected ? 15 : 5,
                        x: 0,
                        y: 0
                    )

                Text(mood.name)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? mood.color : .primary)
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        .onChange(of: isSelected) { _, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            } else {
                isPulsing = false
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        GlowingButton(title: "Save Mood", action: {
            print("Button tapped")
        }, isEnabled: true)
        .padding()

        GlowingButton(title: "Disabled", action: {}, isEnabled: false)
        .padding()

        HStack(spacing: 20) {
            EnhancedMoodButton(mood: .happy, isSelected: true) {
                print("Happy selected")
            }

            EnhancedMoodButton(mood: .sad, isSelected: false) {
                print("Sad selected")
            }
        }
        .padding()
    }
    .background(GradientBackground(timeOfDay: .morning))
}
