//
//  HomeView.swift
//  DailyMoodTracker
//
//  Main screen for logging mood entries with today's timeline
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedMood: MoodType?
    @State private var note: String = ""
    @State private var showingSaveAlert = false
    @FocusState private var isNoteFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 25) {
                        // Date Header
                        VStack(spacing: 4) {
                            Text(Date().formatted(date: .long, time: .omitted))
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text("How are you feeling right now?")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .padding(.top, 20)

                        // Mood Selection
                        VStack(spacing: 15) {
                            HStack(spacing: 12) {
                                MoodButton(mood: .happy, isSelected: selectedMood == .happy) {
                                    selectedMood = .happy
                                }
                                MoodButton(mood: .neutral, isSelected: selectedMood == .neutral) {
                                    selectedMood = .neutral
                                }
                            }

                            HStack(spacing: 12) {
                                MoodButton(mood: .sad, isSelected: selectedMood == .sad) {
                                    selectedMood = .sad
                                }
                                MoodButton(mood: .angry, isSelected: selectedMood == .angry) {
                                    selectedMood = .angry
                                }
                                MoodButton(mood: .sleepy, isSelected: selectedMood == .sleepy) {
                                    selectedMood = .sleepy
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Note Input
                        VStack(alignment: .leading, spacing: 10) {
                            TextField("What's happening? (optional)", text: $note, axis: .vertical)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                                .lineLimit(3...5)
                                .focused($isNoteFieldFocused)
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button("Done") {
                                            isNoteFieldFocused = false
                                        }
                                    }
                                }
                        }
                        .padding(.horizontal)

                        // Log Mood Button
                        Button(action: logMood) {
                            Text("Log Mood")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedMood != nil ? Color.blue : Color.gray)
                                .cornerRadius(12)
                        }
                        .disabled(selectedMood == nil)
                        .padding(.horizontal)

                        // Today's Timeline
                        if !dataManager.getEntriesToday().isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                Divider()
                                    .padding(.vertical, 5)

                                Text("Today's Entries")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(dataManager.getEntriesToday()) { entry in
                                    TimelineEntryRow(entry: entry, onDelete: {
                                        dataManager.deleteEntry(entry)
                                    })
                                }
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Mood Logged", isPresented: $showingSaveAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your mood has been recorded!")
            }
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

// MARK: - Mood Button Component
struct MoodButton: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(mood.emoji)
                    .font(.system(size: 44))

                Text(mood.name)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(isSelected ? mood.color.opacity(0.2) : Color.gray.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? mood.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Timeline Entry Row
struct TimelineEntryRow: View {
    let entry: MoodEntry
    let onDelete: () -> Void
    @State private var showingDeleteAlert = false

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Time and mood color indicator
            VStack(spacing: 6) {
                Text(entry.formattedTime)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                Circle()
                    .fill(entry.mood.color)
                    .frame(width: 10, height: 10)
            }
            .frame(width: 60)

            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Text(entry.mood.emoji)
                        .font(.system(size: 32))

                    Text(entry.mood.name)
                        .font(.headline)

                    Spacer()

                    Button(action: { showingDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .padding(.horizontal)
        .alert("Delete Entry?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("This entry will be permanently deleted.")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(DataManager())
}
