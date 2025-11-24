//
//  InsightsView.swift
//  DailyMoodTracker
//
//  Complete analytics and insights dashboard with all statistics
//

import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject var dataManager: DataManager
    @AppStorage("darkModeEnabled") private var isDarkMode: Bool = true
    @State private var timePeriod: TimePeriod = .week

    enum TimePeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }

    private var theme: ThemeColors {
        isDarkMode ? Color.darkTheme : Color.lightTheme
    }

    var body: some View {
        ZStack {
            // Dynamic theme background
            DarkThemeBackground(isDark: isDarkMode)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    // Header
                    Text("Insights")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(theme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 25)
                        .padding(.top, 20)

                    // Statistics Overview Cards
                    VStack(spacing: 15) {
                        // Top row: Total Entries, Current Streak
                        HStack(spacing: 15) {
                            StatCard(
                                title: "Total Entries",
                                value: "\(dataManager.entries.count)",
                                icon: "calendar",
                                subtitle: "all time",
                                isDark: isDarkMode
                            )

                            StatCard(
                                title: "Current Streak",
                                value: "\(getCurrentStreak())",
                                icon: "flame.fill",
                                subtitle: getCurrentStreak() == 1 ? "day" : "days",
                                isDark: isDarkMode
                            )
                        }

                        // Second row: Longest Streak, This Week
                        HStack(spacing: 15) {
                            StatCard(
                                title: "Longest Streak",
                                value: "\(getLongestStreak())",
                                icon: "⭐",
                                subtitle: getLongestStreak() == 1 ? "day" : "days",
                                isDark: isDarkMode
                            )

                            StatCard(
                                title: "This Week",
                                value: "\(getThisWeekCount())",
                                icon: "chart.bar.fill",
                                subtitle: getThisWeekCount() == 1 ? "entry" : "entries",
                                isDark: isDarkMode
                            )
                        }

                        // Third row: Most Common Mood (All Time)
                        StatCard(
                            title: "Most Common Mood",
                            value: getMostCommonMoodAllTime().emoji,
                            icon: "star.fill",
                            subtitle: getMostCommonMoodAllTime().name,
                            isWide: true,
                            isDark: isDarkMode
                        )
                    }
                    .padding(.horizontal, 25)

                    // Time Period Toggle
                    HStack(spacing: 0) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Button(action: { timePeriod = period }) {
                                Text(period.rawValue)
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(timePeriod == period ? .semibold : .regular)
                                    .foregroundColor(timePeriod == period ? theme.textPrimary : theme.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        timePeriod == period ?
                                        theme.accent : Color.clear
                                    )
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(4)
                    .background((isDarkMode ? Color.black : Color.gray).opacity(0.2))
                    .cornerRadius(12)
                    .padding(.horizontal, 25)

                    // Mood Distribution Section
                    DarkThemeCard(padding: 20, isDark: isDarkMode) {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Mood Distribution")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(theme.textPrimary)

                            if getFilteredEntries().isEmpty {
                                VStack(spacing: 10) {
                                    Image(systemName: "chart.pie")
                                        .font(.system(size: 40))
                                        .foregroundColor(theme.textSecondary.opacity(0.5))

                                    Text("No data for this period")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(theme.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                            } else {
                                VStack(spacing: 15) {
                                    ForEach(MoodType.allCases, id: \.self) { mood in
                                        MoodDistributionBar(
                                            mood: mood,
                                            percentage: calculatePercentage(for: mood),
                                            count: getMoodCount(for: mood),
                                            isDark: isDarkMode
                                        )
                                        .id("\(mood.rawValue)-\(timePeriod.rawValue)")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 25)

                    // Mood Patterns Chart
                    if #available(iOS 16.0, *) {
                        DarkThemeCard(padding: 20, isDark: isDarkMode) {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Mood Patterns")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(theme.textPrimary)

                                MoodPatternsChart(entries: getFilteredEntries())
                                    .frame(height: 200)
                                    .id("chart-\(timePeriod.rawValue)")

                                // Peak happiness insight
                                HStack(spacing: 8) {
                                    Text("☀️")
                                        .font(.system(size: 20))

                                    Text("Peak happiness: \(getPeakHappinessTime())")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(Color.darkTheme.textSecondary)
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                    }

                    // Insight Card
                    DarkThemeCard(padding: 20, isDark: isDarkMode) {
                        HStack(alignment: .top, spacing: 15) {
                            Text("💡")
                                .font(.system(size: 40))

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Insight of the \(timePeriod.rawValue)")
                                    .font(.system(.headline, design: .rounded))
                                    .foregroundColor(theme.textPrimary)

                                Text(generateInsight())
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(theme.textSecondary)
                                    .lineSpacing(4)
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            timePeriod = .week
        }
    }

    // MARK: - Streak Calculations

    private func getCurrentStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        while true {
            let hasEntry = dataManager.entries.contains { entry in
                calendar.isDate(entry.date, inSameDayAs: checkDate)
            }

            if hasEntry {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = previousDay
            } else {
                break
            }
        }

        return streak
    }

    private func getLongestStreak() -> Int {
        guard !dataManager.entries.isEmpty else { return 0 }

        let calendar = Calendar.current
        let sortedEntries = dataManager.entries.sorted { $0.date < $1.date }

        var longestStreak = 0
        var currentStreak = 1
        var previousDate = calendar.startOfDay(for: sortedEntries[0].date)

        for i in 1..<sortedEntries.count {
            let currentDate = calendar.startOfDay(for: sortedEntries[i].date)

            if calendar.isDate(currentDate, equalTo: previousDate, toGranularity: .day) {
                // Same day, don't increment
                continue
            } else if let nextDay = calendar.date(byAdding: .day, value: 1, to: previousDate),
                      calendar.isDate(currentDate, equalTo: nextDay, toGranularity: .day) {
                // Consecutive day
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                // Streak broken
                currentStreak = 1
            }

            previousDate = currentDate
        }

        return max(longestStreak, 1)
    }

    private func getThisWeekCount() -> Int {
        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            return 0
        }

        return dataManager.entries.filter { $0.date >= weekStart }.count
    }

    // MARK: - Helper Functions

    private func getFilteredEntries() -> [MoodEntry] {
        let calendar = Calendar.current
        let now = Date()

        switch timePeriod {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return dataManager.entries.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return dataManager.entries.filter { $0.date >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return dataManager.entries.filter { $0.date >= yearAgo }
        }
    }

    private func getMoodCount(for mood: MoodType) -> Int {
        return getFilteredEntries().filter { $0.mood == mood }.count
    }

    private func calculatePercentage(for mood: MoodType) -> Double {
        let entries = getFilteredEntries()
        guard !entries.isEmpty else { return 0 }
        let count = entries.filter { $0.mood == mood }.count
        return Double(count) / Double(entries.count)
    }

    private func getMostCommonMoodAllTime() -> MoodType {
        let entries = dataManager.entries
        guard !entries.isEmpty else { return .neutral }

        let moodCounts = Dictionary(grouping: entries) { $0.mood }
            .mapValues { $0.count }

        return moodCounts.max(by: { $0.value < $1.value })?.key ?? .neutral
    }

    private func getMostCommonMood() -> MoodType {
        let entries = getFilteredEntries()
        guard !entries.isEmpty else { return .neutral }

        let moodCounts = Dictionary(grouping: entries) { $0.mood }
            .mapValues { $0.count }

        return moodCounts.max(by: { $0.value < $1.value })?.key ?? .neutral
    }

    private func getPeakHappinessTime() -> String {
        let happyEntries = getFilteredEntries().filter { $0.mood == .happy }
        guard !happyEntries.isEmpty else { return "N/A" }

        let timeOfDayCounts = Dictionary(grouping: happyEntries) { $0.date.timeOfDay }
            .mapValues { $0.count }

        guard let peak = timeOfDayCounts.max(by: { $0.value < $1.value })?.key else {
            return "N/A"
        }

        switch peak {
        case .morning: return "Mornings"
        case .afternoon: return "Afternoons"
        case .evening: return "Evenings"
        case .night: return "Nights"
        }
    }

    private func generateInsight() -> String {
        let entries = getFilteredEntries()
        guard !entries.isEmpty else {
            return "Start tracking your moods to get personalized insights!"
        }

        let mostCommon = getMostCommonMood()
        let count = getMoodCount(for: mostCommon)
        let currentStreak = getCurrentStreak()

        let insights = [
            "You've been feeling \(mostCommon.name.lowercased()) most often. Keep tracking to discover patterns! 🌟",
            "You logged \(entries.count) moods this \(timePeriod.rawValue.lowercased()). Great job staying mindful! 💪",
            "Your most common mood is \(mostCommon.name). Understanding this is the first step to emotional awareness! 🎯",
            "You felt \(mostCommon.name.lowercased()) \(count) times. What triggers this mood for you? 🤔",
            "Amazing! You're on a \(currentStreak)-day streak! Keep the momentum going! 🔥"
        ]

        return insights.randomElement() ?? insights[0]
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    var subtitle: String = ""
    var isWide: Bool = false
    var isDark: Bool = true

    private var theme: ThemeColors {
        isDark ? Color.darkTheme : Color.lightTheme
    }

    var body: some View {
        DarkThemeCard(padding: 16, isDark: isDark) {
            VStack(spacing: 10) {
                // Check if icon is emoji or SF Symbol
                if icon.count <= 2 {
                    // Emoji (single character or emoji with modifier)
                    Text(icon)
                        .font(.system(size: isWide ? 40 : 32))
                } else {
                    // SF Symbol
                    Image(systemName: icon)
                        .font(.system(size: isWide ? 36 : 28))
                        .foregroundColor(theme.accent)
                }

                Text(value)
                    .font(.system(isWide ? .title : .title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)

                Text(title)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(theme.textSecondary.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: isWide ? .infinity : nil)
    }
}

// MARK: - Mood Distribution Bar
struct MoodDistributionBar: View {
    let mood: MoodType
    let percentage: Double
    let count: Int
    var isDark: Bool = true

    @State private var animatedPercentage: Double = 0

    private var theme: ThemeColors {
        isDark ? Color.darkTheme : Color.lightTheme
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(mood.emoji)
                    .font(.system(size: 24))

                Text(mood.name)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
                    .frame(width: 70, alignment: .leading)

                Spacer()

                Text("\(count)")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(theme.textSecondary)

                Text("\(Int(percentage * 100))%")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textPrimary)
                    .frame(width: 45, alignment: .trailing)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background bar
                    RoundedRectangle(cornerRadius: 8)
                        .fill((isDark ? Color.white : Color.gray).opacity(0.1))
                        .frame(height: 12)

                    // Filled bar with gradient
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: mood.gradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * animatedPercentage, height: 12)
                }
            }
            .frame(height: 12)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animatedPercentage = percentage
            }
        }
        .onChange(of: percentage) { newPercentage in
            withAnimation(.easeInOut(duration: 0.6)) {
                animatedPercentage = newPercentage
            }
        }
    }
}

// MARK: - Mood Patterns Chart
@available(iOS 16.0, *)
struct MoodPatternsChart: View {
    let entries: [MoodEntry]

    var body: some View {
        if entries.isEmpty {
            VStack(spacing: 10) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.3))

                Text("Not enough data")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
        } else {
            Chart {
                ForEach(aggregatedData(), id: \.date) { data in
                    LineMark(
                        x: .value("Date", data.date),
                        y: .value("Score", data.averageScore)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 3))

                    AreaMark(
                        x: .value("Date", data.date),
                        y: .value("Score", data.averageScore)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "667EEA").opacity(0.3), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
    }

    private func aggregatedData() -> [MoodDataPoint] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.date)
        }

        return grouped.map { date, entries in
            let scores = entries.map { moodScore(for: $0.mood) }
            let average = scores.reduce(0, +) / Double(scores.count)
            return MoodDataPoint(date: date, averageScore: average)
        }
        .sorted { $0.date < $1.date }
    }

    private func moodScore(for mood: MoodType) -> Double {
        switch mood {
        case .happy: return 5.0
        case .neutral: return 3.0
        case .sad: return 2.0
        case .angry: return 1.5
        case .sleepy: return 2.5
        }
    }
}

struct MoodDataPoint {
    let date: Date
    let averageScore: Double
}

#Preview {
    InsightsView()
        .environmentObject(DataManager())
}
