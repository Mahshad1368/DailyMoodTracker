//
//  InsightsView.swift
//  DailyMoodTracker
//
//  Analytics and insights screen showing mood patterns and trends
//

import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var timePeriod: TimePeriod = .week

    enum TimePeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }

    var body: some View {
        ZStack {
            // Dark background
            DarkGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    // Header
                    Text("Insights")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 25)
                        .padding(.top, 20)

                    // Time Period Toggle
                    HStack(spacing: 0) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Button(action: { timePeriod = period }) {
                                Text(period.rawValue)
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(timePeriod == period ? .semibold : .regular)
                                    .foregroundColor(timePeriod == period ? .white : .white.opacity(0.6))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        timePeriod == period ?
                                        LinearGradient(
                                            colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ) : LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(4)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 25)

                    // Mood Distribution Section
                    DarkGlassCard(padding: 20) {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Mood Distribution")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            VStack(spacing: 15) {
                                ForEach(MoodType.allCases, id: \.self) { mood in
                                    MoodDistributionBar(
                                        mood: mood,
                                        percentage: calculatePercentage(for: mood),
                                        count: getMoodCount(for: mood)
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 25)

                    // Mood Patterns Chart
                    if #available(iOS 16.0, *) {
                        DarkGlassCard(padding: 20) {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Mood Patterns")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)

                                MoodPatternsChart(entries: getFilteredEntries())
                                    .frame(height: 200)

                                // Peak happiness insight
                                HStack(spacing: 8) {
                                    Text("☀️")
                                        .font(.system(size: 20))

                                    Text("Peak happiness: \(getPeakHappinessTime())")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                    }

                    // Insight Card
                    DarkGlassCard(padding: 20) {
                        HStack(alignment: .top, spacing: 15) {
                            Text("💡")
                                .font(.system(size: 40))

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Insight of the \(timePeriod.rawValue)")
                                    .font(.system(.headline, design: .rounded))
                                    .foregroundColor(.white)

                                Text(generateInsight())
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineSpacing(4)
                            }
                        }
                    }
                    .padding(.horizontal, 25)

                    // Statistics Cards
                    HStack(spacing: 15) {
                        StatCard(
                            title: "Total Entries",
                            value: "\(getFilteredEntries().count)",
                            icon: "📝"
                        )

                        StatCard(
                            title: "Most Common",
                            value: getMostCommonMood().emoji,
                            icon: "⭐"
                        )
                    }
                    .padding(.horizontal, 25)
                }
                .padding(.bottom, 30)
            }
        }
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

        let insights = [
            "You've been feeling \(mostCommon.name.lowercased()) most often. Keep tracking to discover patterns! 🌟",
            "You logged \(entries.count) moods this \(timePeriod.rawValue.lowercased()). Great job staying mindful! 💪",
            "Your most common mood is \(mostCommon.name). Understanding this is the first step to emotional awareness! 🎯",
            "You felt \(mostCommon.name.lowercased()) \(count) times. What triggers this mood for you? 🤔"
        ]

        return insights.randomElement() ?? insights[0]
    }
}

// MARK: - Mood Distribution Bar
struct MoodDistributionBar: View {
    let mood: MoodType
    let percentage: Double
    let count: Int

    @State private var animatedPercentage: Double = 0

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(mood.emoji)
                    .font(.system(size: 24))

                Text(mood.name)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(width: 70, alignment: .leading)

                Spacer()

                Text("\(count)")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))

                Text("\(Int(percentage * 100))%")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 45, alignment: .trailing)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background bar
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
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

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        DarkGlassCard(padding: 20) {
            VStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 36))

                Text(value)
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(title)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    InsightsView()
        .environmentObject(DataManager())
}
