//
//  HomeView.swift
//  DailyMoodTracker
//
//  Main screen for logging mood entries - Redesigned with modern UI
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedMood: MoodType?
    @State private var note: String = ""
    @State private var showingSaveAlert = false
    @FocusState private var isNoteFieldFocused: Bool

    // Current date for time-based gradient
    @State private var currentDate = Date()

    var body: some View {
        ZStack {
            // Time-based gradient background
            GradientBackground(timeOfDay: currentDate.timeOfDay)

            VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    // Profile Icon
                    Button(action: {
                        // Profile action
                    }) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.9))
                    }

                    Spacer()

                    // Settings Icon
                    Button(action: {
                        // Settings action
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 10)
                .padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        // Personalized Greeting
                        VStack(spacing: 6) {
                            Text("\(currentDate.greeting), User!")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text(currentDate.friendlyDateString)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 10)

                        // Main Glass Card
                        GlassCard(padding: 25) {
                            VStack(spacing: 25) {
                                // Question
                                Text("How are you feeling right now?")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)

                                // Mood Selection - 5 buttons in a row
                                HStack(spacing: 15) {
                                    EnhancedMoodButton(
                                        mood: .happy,
                                        isSelected: selectedMood == .happy
                                    ) {
                                        selectedMood = .happy
                                    }

                                    EnhancedMoodButton(
                                        mood: .neutral,
                                        isSelected: selectedMood == .neutral
                                    ) {
                                        selectedMood = .neutral
                                    }

                                    EnhancedMoodButton(
                                        mood: .sad,
                                        isSelected: selectedMood == .sad
                                    ) {
                                        selectedMood = .sad
                                    }

                                    EnhancedMoodButton(
                                        mood: .angry,
                                        isSelected: selectedMood == .angry
                                    ) {
                                        selectedMood = .angry
                                    }

                                    EnhancedMoodButton(
                                        mood: .sleepy,
                                        isSelected: selectedMood == .sleepy
                                    ) {
                                        selectedMood = .sleepy
                                    }
                                }
                                .frame(maxWidth: .infinity)

                                // Note Input Field
                                HStack(spacing: 12) {
                                    TextField("Add a note...", text: $note, axis: .vertical)
                                        .textFieldStyle(.plain)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.gray.opacity(0.1))
                                        )
                                        .lineLimit(3...5)
                                        .focused($isNoteFieldFocused)
                                }

                                // Save Mood Button
                                GlowingButton(
                                    title: "Save Mood",
                                    action: logMood,
                                    isEnabled: selectedMood != nil,
                                    colors: [Color(hex: "FFD93D"), Color(hex: "FFA500")]
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 30)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isNoteFieldFocused = false
                    }
                }
            }
            .alert("Mood Logged!", isPresented: $showingSaveAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your mood has been recorded! ✨")
            }
        }
        .onAppear {
            // Update current date when view appears
            currentDate = Date()
        }
    }

    private func logMood() {
        guard let mood = selectedMood else { return }

        // Dismiss keyboard
        isNoteFieldFocused = false

        dataManager.addEntry(mood: mood, note: note)

        // Clear form
        selectedMood = nil
        note = ""

        showingSaveAlert = true
    }
}

#Preview {
    HomeView()
        .environmentObject(DataManager())
}
