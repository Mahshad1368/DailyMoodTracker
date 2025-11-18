//
//  MoodFlexWidget.swift
//  MoodFlexWidget
//
//  Created by Mahshad Jafari on 18.11.25.
//

import WidgetKit
import SwiftUI

// MARK: - App Group Configuration
private let appGroupID = "group.com.dailymoodtracker.app"

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> MoodEntry {
        MoodEntry(date: Date(), mood: .happy, note: "Feeling great!")
    }

    func getSnapshot(in context: Context, completion: @escaping (MoodEntry) -> ()) {
        let entry = loadLatestMood() ?? MoodEntry(date: Date(), mood: .happy, note: "Add your first mood!")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Load the latest mood entry
        let currentEntry = loadLatestMood() ?? MoodEntry(date: Date(), mood: .happy, note: "Add your first mood!")

        // Create timeline with current entry
        // The widget will be refreshed when the app calls WidgetCenter.shared.reloadAllTimelines()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [currentEntry], policy: .after(nextUpdate))
        completion(timeline)
    }

    /// Load the latest mood entry from shared UserDefaults
    private func loadLatestMood() -> MoodEntry? {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupID) else {
            print("❌ Widget: Could not access shared UserDefaults")
            return nil
        }

        guard let data = sharedDefaults.data(forKey: "moodEntries") else {
            print("❌ Widget: No mood data found")
            return nil
        }

        do {
            let decoder = JSONDecoder()
            let entries = try decoder.decode([SharedMoodEntry].self, from: data)

            print("✅ Widget: Loaded \(entries.count) mood entries")

            // Get the most recent entry
            guard let latestEntry = entries.first else {
                print("❌ Widget: No entries in array")
                return nil
            }

            print("✅ Widget: Latest mood is \(latestEntry.mood.emoji) at \(latestEntry.formattedTime)")

            return MoodEntry(
                date: latestEntry.date,
                mood: latestEntry.mood,
                note: latestEntry.note
            )
        } catch {
            print("❌ Widget: Error decoding mood entries: \(error)")
            return nil
        }
    }
}

// MARK: - Timeline Entry
struct MoodEntry: TimelineEntry {
    let date: Date
    let mood: MoodType
    let note: String
}

// MARK: - Widget View
struct MoodFlexWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
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

// MARK: - Small Widget View
struct SmallWidgetView: View {
    let entry: MoodEntry

    var body: some View {
        ZStack {
            // Gradient background based on mood
            LinearGradient(
                colors: entry.mood.widgetGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 8) {
                // Large emoji
                Text(entry.mood.emoji)
                    .font(.system(size: 60))

                // Mood name
                Text(entry.mood.name)
                    .font(.headline)
                    .foregroundColor(.white)

                // Time
                Text(entry.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
        }
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    let entry: MoodEntry

    var body: some View {
        ZStack {
            // Gradient background based on mood
            LinearGradient(
                colors: entry.mood.widgetGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack(spacing: 16) {
                // Left side: Large emoji
                Text(entry.mood.emoji)
                    .font(.system(size: 70))

                // Right side: Mood info
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.mood.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(entry.date, style: .time)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))

                    if !entry.note.isEmpty {
                        Text(entry.note)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                    }
                }

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Large Widget View
struct LargeWidgetView: View {
    let entry: MoodEntry

    var body: some View {
        ZStack {
            // Gradient background based on mood
            LinearGradient(
                colors: entry.mood.widgetGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 16) {
                // Top: Large emoji
                Text(entry.mood.emoji)
                    .font(.system(size: 100))

                // Middle: Mood name
                Text(entry.mood.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                // Time
                Text(entry.date, style: .time)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))

                // Note (if available)
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Widget Configuration
struct MoodFlexWidget: Widget {
    let kind: String = "MoodFlexWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                MoodFlexWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                MoodFlexWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Mood Tracker")
        .description("Shows your latest mood")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    MoodFlexWidget()
} timeline: {
    MoodEntry(date: .now, mood: .happy, note: "Feeling great!")
    MoodEntry(date: .now, mood: .sad, note: "Feeling down")
}
