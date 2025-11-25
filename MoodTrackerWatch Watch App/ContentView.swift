//
//  ContentView.swift
//  MoodTrackerWatch Watch App
//
//  Main Watch App interface for quick mood logging
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = WatchDataManager.shared
    @State private var selectedMood: MoodType?
    @State private var showingConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    Text("Log Your Mood")
                        .font(.headline)
                        .padding(.top, 8)

                    // Today's mood count
                    if !dataManager.todayEntries.isEmpty {
                        Text("\(dataManager.todayEntries.count) logged today")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Mood Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(MoodType.allCases, id: \.self) { mood in
                            MoodButton(mood: mood) {
                                logMood(mood)
                            }
                        }
                    }
                    .padding(.horizontal, 4)

                    // Today's Timeline
                    if !dataManager.todayEntries.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Today")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)

                            ForEach(dataManager.todayEntries.prefix(5)) { entry in
                                TimelineEntryRow(entry: entry)
                            }
                        }
                        .padding(.top, 12)
                    }
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("MoodFlex")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Mood Logged", isPresented: $showingConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            if let mood = selectedMood {
                Text("\(mood.emoji) \(mood.name) logged successfully!")
            }
        }
        .onAppear {
            dataManager.loadEntries()
        }
    }

    private func logMood(_ mood: MoodType) {
        selectedMood = mood
        dataManager.addEntry(mood: mood)
        showingConfirmation = true

        // Haptic feedback
        WKInterfaceDevice.current().play(.success)
    }
}

// MARK: - Mood Button
struct MoodButton: View {
    let mood: MoodType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(mood.emoji)
                    .font(.system(size: 32))

                Text(mood.name)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(mood.color.opacity(0.2))
            .foregroundStyle(mood.color)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Timeline Entry Row
struct TimelineEntryRow: View {
    let entry: SharedMoodEntry

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(entry.mood.emoji)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.mood.name)
                    .font(.caption)
                    .fontWeight(.medium)

                Text(timeString)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(entry.mood.color.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    ContentView()
}
