//
//  HistoryView.swift
//  DailyMoodTracker
//
//  Calendar-based view showing mood entries by month - Redesigned with dark theme
//  Supports multiple entries per day
//

import SwiftUI

// Make Date identifiable for sheet(item:) modifier
extension Date: Identifiable {
    public var id: TimeInterval {
        self.timeIntervalSince1970
    }
}

struct HistoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    @State private var viewMode: ViewMode = .calendar

    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]

    enum ViewMode {
        case calendar
        case heatmap
    }

    var body: some View {
        ZStack {
            // Dark gradient background
            DarkGradientBackground()

            VStack(spacing: 0) {
                // View Mode Toggle
                HStack(spacing: 0) {
                    Button(action: { viewMode = .calendar }) {
                        Text("Calendar")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(viewMode == .calendar ? .semibold : .regular)
                            .foregroundColor(viewMode == .calendar ? .white : .white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                viewMode == .calendar ?
                                LinearGradient(
                                    colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) : LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(10)
                    }

                    Button(action: { viewMode = .heatmap }) {
                        Text("Heatmap")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(viewMode == .heatmap ? .semibold : .regular)
                            .foregroundColor(viewMode == .heatmap ? .white : .white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                viewMode == .heatmap ?
                                LinearGradient(
                                    colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) : LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(10)
                    }
                }
                .padding(4)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)

                // Month Navigation
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Text(monthYearString(from: currentDate))
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)

                // Calendar View
                DarkGlassCard(padding: 20) {
                    VStack(spacing: 15) {
                        // Days of Week Header
                        HStack(spacing: 0) {
                            ForEach(daysOfWeek, id: \.self) { day in
                                Text(day)
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.7))
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
                                        isToday: calendar.isDateInToday(date)
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
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .sheet(item: $selectedDate) { date in
                EnhancedDateDetailSheet(
                    date: date,
                    entries: getEntries(for: date),
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

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 6) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, design: .rounded))
                .fontWeight(isToday ? .bold : .medium)
                .foregroundColor(isCurrentMonth ? .white : .white.opacity(0.3))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(isToday ? Color(hex: "667EEA") : Color.clear)
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
    let onDelete: (MoodEntry) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "1A1A2E")
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Date Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formattedDate)
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("\(entries.count) \(entries.count == 1 ? "entry" : "entries")")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 25)
                .padding(.bottom, 20)

                if entries.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.5))

                        Text("No entries for this day")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)

                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(entries) { entry in
                                EnhancedEntryCard(entry: entry, onDelete: {
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
    let onDelete: () -> Void
    @State private var showingDeleteAlert = false

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Time with time-of-day icon
            VStack(spacing: 6) {
                Text(entry.date.timeOfDay.emoji)
                    .font(.system(size: 24))

                Text(entry.formattedTime)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(width: 65)

            // Content with colored left border
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Text(entry.mood.emoji)
                        .font(.system(size: 32))

                    Text(entry.mood.name)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: { showingDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.8))
                    }
                }

                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .lineSpacing(4)
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
                onDelete()
            }
        } message: {
            Text("This entry will be permanently deleted.")
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(DataManager())
}
