//
//  HistoryView.swift
//  DailyMoodTracker
//
//  Calendar-based view showing mood entries by month - Redesigned with dark theme
//  Supports multiple entries per day
//

import SwiftUI
import AVFoundation

// Make Date identifiable for sheet(item:) modifier
extension Date: Identifiable {
    public var id: TimeInterval {
        self.timeIntervalSince1970
    }
}

struct HistoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @AppStorage("darkModeEnabled") private var isDarkMode: Bool = true
    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    @State private var viewMode: ViewMode = .calendar

    enum ViewMode {
        case calendar
        case heatmap
    }

    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]

    private var theme: ThemeColors {
        isDarkMode ? Color.darkTheme : Color.lightTheme
    }

    var body: some View {
        ZStack {
            // Dynamic theme gradient background
            DarkThemeBackground(isDark: isDarkMode)

            VStack(spacing: 0) {
                // Header
                Text("Your Mood Journey")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                    .padding(.bottom, 15)

                // Month Navigation
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(theme.textPrimary)
                    }

                    Spacer()

                    Text(monthYearString(from: currentDate))
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(theme.textPrimary)

                    Spacer()

                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(theme.textPrimary)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)

                // Main Card with Toggle and Content
                DarkThemeCard(padding: 20, isDark: isDarkMode) {
                    VStack(spacing: 20) {
                        // Calendar/Heatmap Toggle
                        HStack(spacing: 0) {
                            // Calendar Button
                            Button(action: { viewMode = .calendar }) {
                                Text("Calendar")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundColor(viewMode == .calendar ? (isDarkMode ? Color.darkTheme.bgDarker : Color.lightTheme.bgLight) : theme.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(viewMode == .calendar ? theme.textPrimary : Color.clear)
                                    )
                            }

                            // Heatmap Button
                            Button(action: { viewMode = .heatmap }) {
                                Text("Heatmap")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundColor(viewMode == .heatmap ? (isDarkMode ? Color.darkTheme.bgDarker : Color.lightTheme.bgLight) : theme.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(viewMode == .heatmap ? theme.textPrimary : Color.clear)
                                    )
                            }
                        }
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill((isDarkMode ? Color.black : Color.gray).opacity(0.3))
                        )

                        // Content based on view mode
                        if viewMode == .calendar {
                            VStack(spacing: 15) {
                                // Days of Week Header
                                HStack(spacing: 0) {
                                    ForEach(daysOfWeek, id: \.self) { day in
                                        Text(day)
                                            .font(.system(.caption, design: .rounded))
                                            .fontWeight(.semibold)
                                            .foregroundColor(theme.textSecondary)
                                            .frame(maxWidth: .infinity)
                                    }
                                }

                                // Calendar Grid
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 12) {
                                    ForEach(generateCalendarDays(), id: \.self) { date in
                                        if let date = date {
                                            EnhancedCalendarDayView(
                                                date: date,
                                                isCurrentMonth: calendar.isDate(date, equalTo: currentDate, toGranularity: .month),
                                                entries: getEntries(for: date),
                                                isToday: calendar.isDateInToday(date),
                                                isDark: isDarkMode
                                            )
                                            .onTapGesture {
                                                let entries = getEntries(for: date)
                                                if !entries.isEmpty {
                                                    selectedDate = date
                                                }
                                            }
                                        } else {
                                            Color.clear
                                                .frame(height: 50)
                                        }
                                    }
                                }
                            }
                        } else {
                            // Heatmap View
                            MoodHeatmapView(
                                currentDate: currentDate,
                                entries: dataManager.entries,
                                isDark: isDarkMode,
                                onDateTap: { date in
                                    let entries = getEntries(for: date)
                                    if !entries.isEmpty {
                                        selectedDate = date
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .sheet(item: $selectedDate) { date in
                EnhancedDateDetailSheet(
                    date: date,
                    entries: getEntries(for: date),
                    isDark: isDarkMode,
                    onDelete: { entry in
                        dataManager.deleteEntry(entry)
                    }
                )
                .environmentObject(dataManager)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Helper Functions

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }

    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }

    private func generateCalendarDays() -> [Date?] {
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)),
              let monthRange = calendar.range(of: .day, in: .month, for: currentDate) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let daysInMonth = monthRange.count

        var days: [Date?] = []

        // Add empty days before the first day of the month
        for _ in 0..<(firstWeekday - 1) {
            days.append(nil)
        }

        // Add all days in the month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }

        return days
    }

    private func getEntries(for date: Date) -> [MoodEntry] {
        return dataManager.getEntries(for: date)
    }
}

// MARK: - Enhanced Calendar Day View
struct EnhancedCalendarDayView: View {
    let date: Date
    let isCurrentMonth: Bool
    let entries: [MoodEntry]
    let isToday: Bool
    let isDark: Bool

    private let calendar = Calendar.current

    private var theme: ThemeColors {
        isDark ? Color.darkTheme : Color.lightTheme
    }

    var body: some View {
        VStack(spacing: 6) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, design: .rounded))
                .fontWeight(isToday ? .bold : .medium)
                .foregroundColor(isCurrentMonth ? theme.textPrimary : theme.textSecondary.opacity(0.3))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(isToday ? theme.accent : Color.clear)
                )

            // Mood indicator dots (show multiple if multiple moods)
            HStack(spacing: 2) {
                ForEach(entries.prefix(3)) { entry in
                    Circle()
                        .fill(entry.mood.color)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Enhanced Date Detail Sheet
struct EnhancedDateDetailSheet: View {
    let date: Date
    let entries: [MoodEntry]
    let isDark: Bool
    let onDelete: (MoodEntry) -> Void
    @Environment(\.dismiss) var dismiss

    private var theme: ThemeColors {
        isDark ? Color.darkTheme : Color.lightTheme
    }

    var body: some View {
        ZStack {
            // Dynamic theme background
            (isDark ? Color.darkTheme.bgDarker : Color.lightTheme.bgLight)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Date Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formattedDate)
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(theme.textPrimary)

                        Text("\(entries.count) \(entries.count == 1 ? "entry" : "entries")")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(theme.textSecondary)
                    }

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(theme.textSecondary)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 25)
                .padding(.bottom, 20)

                if entries.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 50))
                            .foregroundColor(theme.textSecondary.opacity(0.5))

                        Text("No entries for this day")
                            .font(.headline)
                            .foregroundColor(theme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)

                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(entries) { entry in
                                EnhancedEntryCard(entry: entry, isDark: isDark, onDelete: {
                                    onDelete(entry)
                                })
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Enhanced Entry Card
struct EnhancedEntryCard: View {
    let entry: MoodEntry
    let isDark: Bool
    let onDelete: () -> Void
    @State private var showingDeleteAlert = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlayingAudio = false

    private var theme: ThemeColors {
        isDark ? Color.darkTheme : Color.lightTheme
    }

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Time with time-of-day icon
            VStack(spacing: 6) {
                Text(entry.date.timeOfDay.emoji)
                    .font(.system(size: 24))

                Text(entry.formattedTime)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(theme.textSecondary)
            }
            .frame(width: 65)

            // Content with colored left border
            VStack(alignment: .leading, spacing: 12) {
                // Mood header
                HStack(spacing: 10) {
                    Text(entry.mood.emoji)
                        .font(.system(size: 32))

                    Text(entry.mood.name)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(theme.textPrimary)

                    Spacer()

                    Button(action: { showingDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.8))
                    }
                }

                // Note text
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(theme.textSecondary)
                        .lineSpacing(4)
                }

                // Photo attachment
                if let photoData = entry.photoData,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }

                // Audio attachment
                if entry.audioData != nil {
                    HStack(spacing: 12) {
                        Button(action: toggleAudioPlayback) {
                            Image(systemName: isPlayingAudio ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(theme.accent)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Voice Note")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(theme.textPrimary)

                            if let duration = entry.audioDuration {
                                Text(formatDuration(duration))
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(theme.textSecondary)
                            }
                        }

                        Spacer()

                        Image(systemName: "waveform")
                            .font(.system(size: 20))
                            .foregroundColor(theme.accent.opacity(0.5))
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(theme.accent.opacity(0.2))
                    )
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                HStack(spacing: 0) {
                    // Colored left border
                    Rectangle()
                        .fill(entry.mood.color)
                        .frame(width: 4)

                    Color.white.opacity(0.08)
                }
            )
            .cornerRadius(12)
        }
        .alert("Delete Entry?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                stopAudio()
                onDelete()
            }
        } message: {
            Text("This entry will be permanently deleted.")
        }
    }

    // MARK: - Audio Playback

    private func toggleAudioPlayback() {
        if isPlayingAudio {
            stopAudio()
        } else {
            playAudio()
        }
    }

    private func playAudio() {
        guard let audioData = entry.audioData else { return }

        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.delegate = AudioPlayerDelegate(onFinish: {
                isPlayingAudio = false
            })
            audioPlayer?.play()
            isPlayingAudio = true
        } catch {
            print("Error playing audio: \(error)")
        }
    }

    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlayingAudio = false
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Audio Player Delegate
class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish()
    }
}

// MARK: - Mood Heatmap View
struct MoodHeatmapView: View {
    let currentDate: Date
    let entries: [MoodEntry]
    let isDark: Bool
    let onDateTap: (Date) -> Void

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    private var theme: ThemeColors {
        isDark ? Color.darkTheme : Color.lightTheme
    }

    var body: some View {
        VStack(spacing: 15) {
            // Info text
            HStack {
                Text("Activity over the last 12 weeks")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(theme.textSecondary)

                Spacer()

                // Legend
                HStack(spacing: 6) {
                    Text("Less")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(theme.textSecondary)

                    ForEach(0..<5) { intensity in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(heatmapColor(for: intensity))
                            .frame(width: 12, height: 12)
                    }

                    Text("More")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(theme.textSecondary)
                }
            }

            // Heatmap Grid
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Array(generateHeatmapDays().enumerated()), id: \.offset) { index, date in
                    HeatmapDayCell(
                        date: date,
                        entries: getEntries(for: date),
                        isDark: isDark
                    )
                    .onTapGesture {
                        onDateTap(date)
                    }
                }
            }
        }
        .padding(.vertical, 10)
    }

    private func generateHeatmapDays() -> [Date] {
        var days: [Date] = []
        let weeksToShow = 12
        let totalDays = weeksToShow * 7

        // Start from 12 weeks ago
        guard let startDate = calendar.date(byAdding: .day, value: -totalDays, to: currentDate) else {
            return days
        }

        // Generate dates for each day
        for dayOffset in 0..<totalDays {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) {
                days.append(date)
            }
        }

        return days
    }

    private func getEntries(for date: Date) -> [MoodEntry] {
        return entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private func heatmapColor(for intensity: Int) -> Color {
        switch intensity {
        case 0: return (isDark ? Color.white : Color.gray).opacity(0.1)
        case 1: return theme.accent.opacity(0.3)
        case 2: return theme.accent.opacity(0.5)
        case 3: return theme.accent.opacity(0.7)
        default: return theme.accent
        }
    }
}

// MARK: - Heatmap Day Cell
struct HeatmapDayCell: View {
    let date: Date
    let entries: [MoodEntry]
    let isDark: Bool

    private var theme: ThemeColors {
        isDark ? Color.darkTheme : Color.lightTheme
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(cellColor)
            .frame(height: 35)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke((isDark ? Color.white : Color.gray).opacity(0.1), lineWidth: 0.5)
            )
    }

    private var cellColor: Color {
        let count = entries.count

        guard count > 0 else {
            return (isDark ? Color.white : Color.gray).opacity(0.05)
        }

        // Get the most recent mood for this date
        guard let recentMood = entries.first?.mood else {
            return theme.accent.opacity(0.3)
        }

        // Color intensity based on number of entries
        switch count {
        case 1:
            return recentMood.color.opacity(0.4)
        case 2:
            return recentMood.color.opacity(0.6)
        case 3:
            return recentMood.color.opacity(0.8)
        default:
            // Multiple entries - show dominant mood color
            let moodCounts = Dictionary(grouping: entries, by: { $0.mood })
            if let dominantMood = moodCounts.max(by: { $0.value.count < $1.value.count })?.key {
                return dominantMood.color
            } else {
                return recentMood.color
            }
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(DataManager())
}
