//
//  MoodTrackerWidget.swift
//  MoodTrackerWidget
//
//  Complete widget implementation for Daily Mood Tracker
//  Supports: Small, Medium, Large, and Lock Screen widgets
//

import WidgetKit
import SwiftUI

// MARK: - App Group Configuration
let appGroupID = "group.com.dailymoodtracker.app"

// MARK: - Widget Timeline Provider
struct MoodProvider: TimelineProvider {
    func placeholder(in context: Context) -> MoodEntry {
        MoodEntry(date: Date(), dominantMood: .happy, entries: [], entryCount: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (MoodEntry) -> Void) {
        let entry = loadCurrentMoodData()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MoodEntry>) -> Void) {
        let currentEntry = loadCurrentMoodData()

        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [currentEntry], policy: .after(nextUpdate))

        completion(timeline)
    }

    private func loadCurrentMoodData() -> MoodEntry {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupID) else {
            return MoodEntry(date: Date(), dominantMood: .neutral, entries: [], entryCount: 0)
        }

        // Load mood entries from shared UserDefaults
        guard let data = sharedDefaults.data(forKey: "moodEntries"),
              let allEntries = try? JSONDecoder().decode([SharedMoodEntry].self, from: data) else {
            return MoodEntry(date: Date(), dominantMood: .neutral, entries: [], entryCount: 0)
        }

        // Filter today's entries
        let todayEntries = allEntries.filter { Calendar.current.isDateInToday($0.date) }

        // Calculate dominant mood
        let dominantMood = calculateDominantMood(from: todayEntries)

        return MoodEntry(
            date: Date(),
            dominantMood: dominantMood,
            entries: todayEntries,
            entryCount: todayEntries.count
        )
    }

    private func calculateDominantMood(from entries: [SharedMoodEntry]) -> MoodType {
        guard !entries.isEmpty else { return .neutral }

        // Count occurrences of each mood
        let moodCounts = Dictionary(grouping: entries, by: { $0.mood })
            .mapValues { $0.count }

        // Find mood with highest count
        guard let dominant = moodCounts.max(by: { $0.value < $1.value }) else {
            return .neutral
        }

        return dominant.key
    }
}

// MARK: - Widget Timeline Entry
struct MoodEntry: TimelineEntry {
    let date: Date
    let dominantMood: MoodType
    let entries: [SharedMoodEntry]
    let entryCount: Int
}

// MARK: - Small Widget View (2x2)
struct SmallWidgetView: View {
    let entry: MoodEntry

    var body: some View {
        ZStack {
            // Background - use happy55 image for happy mood, gradient for others
            if entry.dominantMood == .happy {
                Image("happy55")
                    .resizable()
                    .scaledToFill()
                    .overlay(Color.black.opacity(0.3)) // Darken for text readability
            } else {
                LinearGradient(
                    colors: entry.dominantMood.widgetGradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            VStack(spacing: 12) {
                // Mood emoji
                Text(entry.dominantMood.emoji)
                    .font(.system(size: 60))

                // Mood name
                Text(entry.dominantMood.name)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                // Entry count
                if entry.entryCount > 0 {
                    Text("\(entry.entryCount) \(entry.entryCount == 1 ? "entry" : "entries")")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                } else {
                    Text("No mood yet")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
        }
    }
}

// MARK: - Medium Widget View (4x2)
struct MediumWidgetView: View {
    let entry: MoodEntry

    var body: some View {
        ZStack {
            // Background - use happy55 image for happy mood, gradient for others
            if entry.dominantMood == .happy {
                Image("happy55")
                    .resizable()
                    .scaledToFill()
                    .overlay(Color.black.opacity(0.3)) // Darken for text readability
            } else {
                LinearGradient(
                    colors: entry.dominantMood.widgetGradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            HStack(spacing: 20) {
                // Left: Dominant mood
                VStack(spacing: 8) {
                    Text(entry.dominantMood.emoji)
                        .font(.system(size: 50))

                    Text(entry.dominantMood.name)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("\(entry.entryCount) today")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(width: 90)

                Divider()
                    .background(Color.white.opacity(0.3))

                // Right: Timeline of recent moods
                if entry.entries.isEmpty {
                    VStack {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.6))
                        Text("No moods logged yet")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Moods")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.9))

                        ForEach(entry.entries.prefix(3)) { moodEntry in
                            HStack(spacing: 8) {
                                Text(moodEntry.mood.emoji)
                                    .font(.system(size: 24))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(moodEntry.mood.name)
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)

                                    Text(moodEntry.formattedTime)
                                        .font(.system(.caption2, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))
                                }

                                Spacer()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
    }
}

// MARK: - Large Widget View (4x4)
struct LargeWidgetView: View {
    let entry: MoodEntry

    var body: some View {
        ZStack {
            // Background - use happy55 image for happy mood, gradient for others
            if entry.dominantMood == .happy {
                Image("happy55")
                    .resizable()
                    .scaledToFill()
                    .overlay(Color.black.opacity(0.3)) // Darken for text readability
            } else {
                LinearGradient(
                    colors: entry.dominantMood.widgetGradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            VStack(spacing: 15) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today's Mood")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("\(entry.entryCount) \(entry.entryCount == 1 ? "entry" : "entries")")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }

                    Spacer()

                    // Dominant mood indicator
                    VStack(spacing: 4) {
                        Text(entry.dominantMood.emoji)
                            .font(.system(size: 40))

                        Text(entry.dominantMood.name)
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }

                Divider()
                    .background(Color.white.opacity(0.3))

                // Timeline of all moods
                if entry.entries.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.6))
                        Text("No moods logged today")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                        Text("Open the app to track your mood")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(entry.entries) { moodEntry in
                                HStack(alignment: .top, spacing: 12) {
                                    // Time
                                    Text(moodEntry.formattedTime)
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundColor(.white.opacity(0.9))
                                        .frame(width: 50, alignment: .leading)

                                    // Mood emoji
                                    Text(moodEntry.mood.emoji)
                                        .font(.system(size: 28))

                                    // Mood details
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(moodEntry.mood.name)
                                            .font(.system(.subheadline, design: .rounded))
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)

                                        if !moodEntry.note.isEmpty {
                                            Text(moodEntry.note)
                                                .font(.system(.caption, design: .rounded))
                                                .foregroundColor(.white.opacity(0.8))
                                                .lineLimit(2)
                                        }
                                    }

                                    Spacer()
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Lock Screen Widgets (iOS 16+)

// Circular Lock Screen Widget
@available(iOS 16.0, *)
struct CircularLockScreenView: View {
    let entry: MoodEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 2) {
                Text(entry.dominantMood.emoji)
                    .font(.system(size: 32))

                Text("\(entry.entryCount)")
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.bold)
            }
        }
    }
}

// Rectangular Lock Screen Widget
@available(iOS 16.0, *)
struct RectangularLockScreenView: View {
    let entry: MoodEntry

    var body: some View {
        HStack(spacing: 8) {
            Text(entry.dominantMood.emoji)
                .font(.system(size: 28))

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.dominantMood.name)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)

                Text("\(entry.entryCount) \(entry.entryCount == 1 ? "entry" : "entries") today")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }
}

// Inline Lock Screen Widget
@available(iOS 16.0, *)
struct InlineLockScreenView: View {
    let entry: MoodEntry

    var body: some View {
        HStack(spacing: 4) {
            Text(entry.dominantMood.emoji)
                .font(.system(size: 16))

            Text(entry.dominantMood.name)
                .font(.system(.caption, design: .rounded))

            Text("(\(entry.entryCount))")
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Widget Definitions

struct MoodTrackerWidget: Widget {
    let kind: String = "MoodTrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MoodProvider()) { entry in
            MoodTrackerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Mood Tracker")
        .description("Track your daily moods at a glance")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct MoodTrackerWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: MoodEntry

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// Lock Screen Widget (iOS 16+)
@available(iOS 16.0, *)
struct MoodTrackerLockScreenWidget: Widget {
    let kind: String = "MoodTrackerLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MoodProvider()) { entry in
            MoodTrackerLockScreenEntryView(entry: entry)
        }
        .configurationDisplayName("Mood Lock Screen")
        .description("Show your mood on the lock screen")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

@available(iOS 16.0, *)
struct MoodTrackerLockScreenEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: MoodEntry

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            CircularLockScreenView(entry: entry)
        case .accessoryRectangular:
            RectangularLockScreenView(entry: entry)
        case .accessoryInline:
            InlineLockScreenView(entry: entry)
        default:
            CircularLockScreenView(entry: entry)
        }
    }
}

// MARK: - Widget Bundle
@main
struct MoodTrackerWidgetBundle: WidgetBundle {
    var body: some Widget {
        MoodTrackerWidget()
        if #available(iOS 16.0, *) {
            MoodTrackerLockScreenWidget()
        }
    }
}

// MARK: - Preview
struct MoodTrackerWidget_Previews: PreviewProvider {
    static var previews: some View {
        let sampleEntry = MoodEntry(
            date: Date(),
            dominantMood: .happy,
            entries: [
                SharedMoodEntry(id: UUID(), date: Date(), mood: .happy, note: "Feeling great!"),
                SharedMoodEntry(id: UUID(), date: Date().addingTimeInterval(-3600), mood: .neutral, note: "Just okay"),
                SharedMoodEntry(id: UUID(), date: Date().addingTimeInterval(-7200), mood: .happy, note: "")
            ],
            entryCount: 3
        )

        Group {
            MoodTrackerWidgetEntryView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            MoodTrackerWidgetEntryView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            MoodTrackerWidgetEntryView(entry: sampleEntry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
