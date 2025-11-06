//
//  OnboardingView.swift
//  DailyMoodTracker
//
//  Three-slide onboarding flow shown on first app launch
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            // Different gradient backgrounds for each slide
            Group {
                switch currentPage {
                case 0:
                    OnboardingGradient(type: .welcome)
                case 1:
                    OnboardingGradient(type: .awareness)
                default:
                    OnboardingGradient(type: .patterns)
                }
            }
            .transition(.opacity)

            VStack(spacing: 0) {
                // Skip button
                if currentPage < 2 {
                    HStack {
                        Spacer()
                        Button(action: completeOnboarding) {
                            Text("Skip")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                } else {
                    Spacer()
                        .frame(height: 60)
                }

                TabView(selection: $currentPage) {
                    // Slide 1: Welcome
                    OnboardingSlide1()
                        .tag(0)

                    // Slide 2: Build Awareness
                    OnboardingSlide2()
                        .tag(1)

                    // Slide 3: Discover Patterns
                    OnboardingSlide3()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                // Bottom buttons
                HStack(spacing: 20) {
                    if currentPage < 2 {
                        Button(action: nextPage) {
                            Text("Next")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.2)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                    } else {
                        GlowingButton(
                            title: "Get Started!",
                            action: completeOnboarding,
                            isEnabled: true,
                            colors: [Color(hex: "FFD93D"), Color(hex: "FFA500")]
                        )
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .animation(.easeInOut, value: currentPage)
    }

    private func nextPage() {
        withAnimation {
            currentPage += 1
        }
    }

    private func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

// MARK: - Slide 1: Welcome
struct OnboardingSlide1: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Floating animated emojis
            ZStack {
                FloatingEmoji(emoji: "😊", offset: CGSize(width: -60, height: -40), delay: 0.0, isAnimating: $isAnimating)
                FloatingEmoji(emoji: "😔", offset: CGSize(width: 60, height: -60), delay: 0.2, isAnimating: $isAnimating)
                FloatingEmoji(emoji: "😡", offset: CGSize(width: -80, height: 20), delay: 0.4, isAnimating: $isAnimating)
                FloatingEmoji(emoji: "😴", offset: CGSize(width: 70, height: 30), delay: 0.6, isAnimating: $isAnimating)
                FloatingEmoji(emoji: "😐", offset: CGSize(width: 0, height: -80), delay: 0.3, isAnimating: $isAnimating)
            }
            .frame(height: 200)

            VStack(spacing: 20) {
                Text("Welcome to\nDaily Mood Tracker!")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Track your emotions, understand your feelings, and discover patterns to improve your well-being.")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(6)
            }

            Spacer()
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Slide 2: Build Awareness
struct OnboardingSlide2: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Calendar illustration using SF Symbols
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 200, height: 200)

                Image(systemName: "calendar")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
            }

            VStack(spacing: 20) {
                Text("Build Your\nEmotional Awareness")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Log your moods daily to see your emotional journey unfold and build a deeper connection with yourself.")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(6)
            }

            Spacer()
        }
    }
}

// MARK: - Slide 3: Discover Patterns
struct OnboardingSlide3: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Chart illustration using SF Symbols
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 200, height: 200)

                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
            }

            VStack(spacing: 20) {
                Text("Discover Your\nPatterns")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Gain valuable insights into your mental well-being and identify triggers to build better, healthier habits.")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(6)
            }

            Spacer()
        }
    }
}

// MARK: - Floating Emoji Component
struct FloatingEmoji: View {
    let emoji: String
    let offset: CGSize
    let delay: Double
    @Binding var isAnimating: Bool

    @State private var yOffset: CGFloat = 0

    var body: some View {
        Text(emoji)
            .font(.system(size: 50))
            .offset(x: offset.width, y: offset.height + yOffset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    yOffset = isAnimating ? -20 : 20
                }
            }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
