//
//  HistoryView.swift
//  DailyMoodTracker
//
//  Calendar-based view showing mood entries by month
//  Supports multiple entries per day
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    @State private var showingDateDetail = false

    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Month/Year Header
                Text(monthYearString(from: currentDate))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                    .padding(.bottom, 30)

                // Month Navigation
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    Text(monthYearString(from: currentDate))
                        .font(.title3)
                        .fontWeight(.semibold)

                    Spacer()

                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)

                // Days of Week Header
                HStack(spacing: 0) {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)

                // Calendar Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 15) {
                    ForEach(generateCalendarDays(), id: \.self) { date in
                        if let date = date {
                            CalendarDayView(
                                date: date,
                                isCurrentMonth: calendar.isDate(date, equalTo: currentDate, toGranularity: .month),
                                entries: getEntries(for: date),
                                isToday: calendar.isDateInToday(date)
                            )
                            .onTapGesture {
                                let entries = getEntries(for: date)
                                if !entries.isEmpty {
                                    selectedDate = date
                                    showingDateDetail = true
                                }
                            }
                        } else {
                            Color.clear
                                .frame(height: 44)
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingDateDetail) {
                if let date = selectedDate {
                    DateDetailSheet(
                        date: date,
                        entries: getEntries(for: date),
                        onDelete: { entry in
                            dataManager.deleteEntry(entry)
                        }
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
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

// MARK: - Calendar Day View
struct CalendarDayView: View {
    let date: Date
    let isCurrentMonth: Bool
    let entries: [MoodEntry]
    let isToday: Bool

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16))
                .fontWeight(isToday ? .semibold : .regular)
                .foregroundColor(isCurrentMonth ? .primary : .gray.opacity(0.3))
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(isToday ? Color.blue : Color.clear)
                )
                .foregroundColor(isToday ? .white : (isCurrentMonth ? .primary : .gray.opacity(0.3)))

            // Mood indicator dots (show multiple if multiple moods)
            HStack(spacing: 3) {
                ForEach(entries.prefix(3)) { entry in
                    Circle()
                        .fill(entry.mood.color)
                        .frame(width: 5, height: 5)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Date Detail Sheet
struct DateDetailSheet: View {
    let date: Date
    let entries: [MoodEntry]
    let onDelete: (MoodEntry) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Date Header
                Text(formattedDate)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 25)
                    .padding(.top, 25)
                    .padding(.bottom, 20)

                if entries.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)

                        Text("No entries for this day")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)

                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(entries) { entry in
                                DateDetailEntryRow(entry: entry, onDelete: {
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
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

// MARK: - Date Detail Entry Row
struct DateDetailEntryRow: View {
    let entry: MoodEntry
    let onDelete: () -> Void
    @State private var showingDeleteAlert = false

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Time and color indicator
            VStack(spacing: 6) {
                Text(entry.formattedTime)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                Circle()
                    .fill(entry.mood.color)
                    .frame(width: 10, height: 10)
            }
            .frame(width: 65)

            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Text(entry.mood.emoji)
                        .font(.system(size: 36))

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
                        .lineSpacing(4)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(entry.mood.color.opacity(0.08))
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
