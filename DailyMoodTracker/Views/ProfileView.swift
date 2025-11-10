//
//  ProfileView.swift
//  DailyMoodTracker
//
//  User profile with statistics and settings
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    @AppStorage("userName") private var userName: String = "User"
    @State private var isEditingName = false
    @State private var editedName = ""

    var body: some View {
        ZStack {
            // Dark gradient background
            DarkGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    // Header with close button
                    HStack {
                        Text("Profile")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Spacer()

                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)

                    // User Info Card
                    GlassCard(padding: 20) {
                        VStack(spacing: 15) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)

                                Text(userName.prefix(1).uppercased())
                                    .font(.system(size: 48, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }

                            // Name
                            if isEditingName {
                                HStack {
                                    TextField("Your name", text: $editedName)
                                        .textFieldStyle(.plain)
                                        .font(.system(.title3, design: .rounded))
                                        .fontWeight(.semibold)
                                        .multilineTextAlignment(.center)
                                        .padding(8)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)

                                    Button(action: saveName) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.green)
                                    }
                                }
                            } else {
                                HStack {
                                    Text(userName)
                                        .font(.system(.title2, design: .rounded))
                                        .fontWeight(.semibold)

                                    Button(action: startEditingName) {
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.title3)
                                            .foregroundColor(.blue.opacity(0.8))
                                    }
                                }
                            }

                            Text("Mood Tracker User")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Statistics Cards
                    VStack(spacing: 15) {
                        // Total Entries & Streak
                        HStack(spacing: 15) {
                            ProfileStatCard(
                                icon: "calendar",
                                value: "\(dataManager.entries.count)",
                                label: "Total Entries",
                                color: Color(hex: "667EEA")
                            )

                            ProfileStatCard(
                                icon: "flame.fill",
                                value: "\(calculateStreak())d",
                                label: "Current Streak",
                                color: Color(hex: "FF6B6B")
                            )
                        }

                        // This Week & Most Common
                        HStack(spacing: 15) {
                            ProfileStatCard(
                                icon: "chart.bar.fill",
                                value: "\(getThisWeekCount())",
                                label: "This Week",
                                color: Color(hex: "4ECDC4")
                            )

                            ProfileStatCard(
                                icon: mostCommonMood.emoji,
                                value: mostCommonMood.name,
                                label: "Most Common",
                                color: mostCommonMood.color
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    // Mood Distribution
                    GlassCard(padding: 20) {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Mood Distribution")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.semibold)

                            ForEach(MoodType.allCases, id: \.self) { mood in
                                ProfileMoodDistributionBar(
                                    mood: mood,
                                    percentage: getMoodPercentage(mood: mood),
                                    count: getMoodCount(mood: mood)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Recent Activity
                    if !dataManager.entries.isEmpty {
                        GlassCard(padding: 20) {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Recent Activity")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.semibold)

                                ForEach(dataManager.entries.prefix(5)) { entry in
                                    HStack {
                                        Text(entry.mood.emoji)
                                            .font(.title2)

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(entry.mood.name)
                                                .font(.system(.subheadline, design: .rounded))
                                                .fontWeight(.medium)

                                            Text(entry.formattedTime)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }

                                        Spacer()

                                        Text(formatRelativeDate(entry.date))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 8)

                                    if entry.id != dataManager.entries.prefix(5).last?.id {
                                        Divider()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // App Info
                    VStack(spacing: 8) {
                        Text("Daily Mood Tracker")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))

                        Text("Version 1.0")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
        }
    }

    // MARK: - Helper Functions

    private func startEditingName() {
        editedName = userName
        isEditingName = true
    }

    private func saveName() {
        if !editedName.trimmingCharacters(in: .whitespaces).isEmpty {
            userName = editedName.trimmingCharacters(in: .whitespaces)
        }
        isEditingName = false
    }

    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        while true {
            let hasEntry = dataManager.entries.contains { entry in
                calendar.isDate(entry.date, inSameDayAs: checkDate)
            }

            if hasEntry {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }

        return streak
    }

    private func getThisWeekCount() -> Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()

        return dataManager.entries.filter { entry in
            entry.date >= startOfWeek
        }.count
    }

    private var mostCommonMood: MoodType {
        let moodCounts = Dictionary(grouping: dataManager.entries, by: { $0.mood })
            .mapValues { $0.count }

        return moodCounts.max(by: { $0.value < $1.value })?.key ?? .neutral
    }

    private func getMoodCount(mood: MoodType) -> Int {
        dataManager.entries.filter { $0.mood == mood }.count
    }

    private func getMoodPercentage(mood: MoodType) -> Double {
        guard !dataManager.entries.isEmpty else { return 0 }
        let count = getMoodCount(mood: mood)
        return Double(count) / Double(dataManager.entries.count)
    }

    private func formatRelativeDate(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Profile Stat Card Component
struct ProfileStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)

                if icon.count == 1 {
                    // Emoji
                    Text(icon)
                        .font(.system(size: 30))
                } else {
                    // SF Symbol
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(color)
                }
            }

            Text(value)
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)

            Text(label)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
    }
}

// MARK: - Profile Mood Distribution Bar Component
struct ProfileMoodDistributionBar: View {
    let mood: MoodType
    let percentage: Double
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(mood.emoji)
                    .font(.title3)

                Text(mood.name)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)

                Spacer()

                Text("\(count)")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 8)

                    // Filled portion
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: mood.widgetGradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * percentage, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(DataManager())
}
