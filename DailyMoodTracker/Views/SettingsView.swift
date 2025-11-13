//
//  SettingsView.swift
//  DailyMoodTracker
//
//  App settings and preferences - No statistics, only configuration
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss

    // User preferences
    @State private var userName: String = UserDefaults.standard.string(forKey: "userName") ?? "User"
    @State private var dailyReminderEnabled: Bool = UserDefaults.standard.bool(forKey: "dailyReminderEnabled")
    @State private var reminderTime: Date = {
        if let savedTime = UserDefaults.standard.object(forKey: "reminderTime") as? Date {
            return savedTime
        }
        var components = DateComponents()
        components.hour = 20 // 8 PM default
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    @State private var darkModeEnabled: Bool = UserDefaults.standard.bool(forKey: "darkModeEnabled")

    // Alerts
    @State private var showingDeleteAlert = false
    @State private var showingExportSheet = false

    var body: some View {
        ZStack {
            // Dark gradient background
            DarkGradientBackground()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundColor(.white)
                        }

                        Text("Settings")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)

                    // User Profile Section
                    DarkGlassCard(padding: 20) {
                        VStack(spacing: 20) {
                            Text("👤")
                                .font(.system(size: 60))

                            VStack(spacing: 12) {
                                Text("Your Name")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.white.opacity(0.7))

                                TextField("Enter your name", text: $userName)
                                    .textFieldStyle(.plain)
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                    .onChange(of: userName) { newValue in
                                        UserDefaults.standard.set(newValue, forKey: "userName")
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 25)

                    // Notifications Section
                    DarkGlassCard(padding: 20) {
                        VStack(alignment: .leading, spacing: 20) {
                            Label("Notifications", systemImage: "bell.fill")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.white)

                            // Daily Reminder Toggle
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Daily Reminder")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(.white)

                                    Text("Get reminded to log your mood")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.white.opacity(0.6))
                                }

                                Spacer()

                                Toggle("", isOn: $dailyReminderEnabled)
                                    .labelsHidden()
                                    .tint(Color(hex: "667EEA"))
                                    .onChange(of: dailyReminderEnabled) { newValue in
                                        UserDefaults.standard.set(newValue, forKey: "dailyReminderEnabled")
                                        if newValue {
                                            requestNotificationPermission()
                                            scheduleDailyNotification(at: reminderTime)
                                        } else {
                                            cancelDailyNotification()
                                        }
                                    }
                            }

                            // Reminder Time Picker
                            if dailyReminderEnabled {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Reminder Time")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))

                                    DatePicker(
                                        "",
                                        selection: $reminderTime,
                                        displayedComponents: .hourAndMinute
                                    )
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .colorScheme(.dark)
                                    .onChange(of: reminderTime) { newValue in
                                        UserDefaults.standard.set(newValue, forKey: "reminderTime")
                                        if dailyReminderEnabled {
                                            scheduleDailyNotification(at: newValue)
                                        }
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                    }
                    .padding(.horizontal, 25)

                    // Appearance Section
                    DarkGlassCard(padding: 20) {
                        VStack(alignment: .leading, spacing: 20) {
                            Label("Appearance", systemImage: "paintbrush.fill")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.white)

                            // Dark & Light Mode Toggle
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Dark Mode")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(.white)

                                    Text("Switch between light and dark themes")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.white.opacity(0.6))
                                }

                                Spacer()

                                Toggle("", isOn: $darkModeEnabled)
                                    .labelsHidden()
                                    .tint(Color(hex: "667EEA"))
                                    .onChange(of: darkModeEnabled) { newValue in
                                        UserDefaults.standard.set(newValue, forKey: "darkModeEnabled")
                                        // Note: In production, you'd apply color scheme here
                                        // For now, app uses dark theme by default
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 25)

                    // Data Management Section
                    DarkGlassCard(padding: 20) {
                        VStack(alignment: .leading, spacing: 20) {
                            Label("Data Management", systemImage: "externaldrive.fill")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.white)

                            // Export Data Button
                            Button(action: { showingExportSheet = true }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Export Data")
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundColor(.white)

                                        Text("Save your mood history")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(.white.opacity(0.6))
                                    }

                                    Spacer()

                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(Color(hex: "667EEA"))
                                }
                            }

                            Divider()
                                .background(Color.white.opacity(0.2))

                            // Delete All Data Button
                            Button(action: { showingDeleteAlert = true }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Delete All Data")
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundColor(.red.opacity(0.9))

                                        Text("Permanently remove all entries")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(.white.opacity(0.6))
                                    }

                                    Spacer()

                                    Image(systemName: "trash")
                                        .foregroundColor(.red.opacity(0.7))
                                }
                            }

                            #if DEBUG
                            Divider()
                                .background(Color.white.opacity(0.2))

                            // Insert Mock Data Button (Debug Only)
                            Button(action: insertMockData) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Insert Mock Data")
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundColor(Color(hex: "667EEA"))

                                        Text("Add 3 months of test entries (debug)")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(.white.opacity(0.6))
                                    }

                                    Spacer()

                                    Image(systemName: "wand.and.stars")
                                        .foregroundColor(Color(hex: "667EEA"))
                                }
                            }
                            #endif
                        }
                    }
                    .padding(.horizontal, 25)

                    // About Section
                    DarkGlassCard(padding: 20) {
                        VStack(alignment: .leading, spacing: 20) {
                            Label("About", systemImage: "info.circle.fill")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.white)

                            // Version
                            HStack {
                                Text("Version")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.white)

                                Spacer()

                                Text("1.0.0")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                            }

                            Divider()
                                .background(Color.white.opacity(0.2))

                            // Privacy Policy
                            Button(action: {
                                // Open privacy policy
                            }) {
                                HStack {
                                    Text("Privacy Policy")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(.white)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }

                            Divider()
                                .background(Color.white.opacity(0.2))

                            // Rate App
                            Button(action: {
                                // Open App Store rating
                            }) {
                                HStack {
                                    Text("Rate This App")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(.white)

                                    Spacer()

                                    Image(systemName: "star.fill")
                                        .foregroundColor(Color(hex: "FFD93D"))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .alert("Delete All Data?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataManager.entries = []
                // Force save empty array
                UserDefaults.standard.removeObject(forKey: "moodEntries")
            }
        } message: {
            Text("This will permanently delete all your mood entries. This action cannot be undone.")
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportDataView(entries: dataManager.entries)
        }
    }

    // MARK: - Notification Functions

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            } else {
                print("⚠️ Notification permission denied")
            }
        }
    }

    private func scheduleDailyNotification(at time: Date) {
        // Cancel existing notification first
        cancelDailyNotification()

        let center = UNUserNotificationCenter.current()

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to Log Your Mood 😊"
        content.body = "How are you feeling today? Take a moment to reflect."
        content.sound = .default
        content.badge = 1

        // Extract hour and minute from selected time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)

        // Create trigger that repeats daily at specified time
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        // Create request with unique identifier
        let request = UNNotificationRequest(
            identifier: "dailyMoodReminder",
            content: content,
            trigger: trigger
        )

        // Schedule notification
        center.add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("✅ Daily notification scheduled for \(components.hour ?? 0):\(String(format: "%02d", components.minute ?? 0))")
            }
        }
    }

    private func cancelDailyNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyMoodReminder"])
        print("🔕 Daily notification cancelled")
    }
}

// MARK: - Export Data View
struct ExportDataView: View {
    let entries: [MoodEntry]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A1A2E")
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Export Your Data")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Choose how you'd like to export your mood history")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    VStack(spacing: 15) {
                        Button(action: exportAsText) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .font(.title2)
                                Text("Export as Text")
                                    .font(.system(.headline, design: .rounded))
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }

                        Button(action: exportAsCSV) {
                            HStack {
                                Image(systemName: "tablecells")
                                    .font(.title2)
                                Text("Export as CSV")
                                    .font(.system(.headline, design: .rounded))
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 25)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }

    private func exportAsText() {
        let text = entries.map { "\($0.formattedDate) \($0.formattedTime) - \($0.mood.name): \($0.note)" }
            .joined(separator: "\n")

        shareText(text)
    }

    private func exportAsCSV() {
        var csv = "Date,Time,Mood,Note\n"
        csv += entries.map { "\($0.formattedDate),\($0.formattedTime),\($0.mood.name),\"\($0.note)\"" }
            .joined(separator: "\n")

        shareText(csv)
    }

    private func shareText(_ text: String) {
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )

        // For iPad - set popover source
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = UIApplication.shared.windows.first
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {

            // Find the topmost view controller
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }

            topVC.present(activityVC, animated: true)
        }
    }

    private func insertMockData() {
        let calendar = Calendar.current
        let today = Date()
        let moods = MoodType.allCases
        let notes = [
            "Had a great day at work!",
            "Feeling tired but content",
            "Relaxing evening with friends",
            "Productive morning session",
            "Just finished a good workout",
            "Enjoying some quiet time",
            "Had an interesting conversation",
            "Feeling grateful today",
            "Just woke up feeling refreshed",
            "End of day reflection",
            ""
        ]

        // Generate entries for past 3 months (90 days)
        for dayOffset in 0..<90 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }

            // Randomly generate 1-3 entries per day
            let entriesPerDay = Int.random(in: 1...3)

            for entryIndex in 0..<entriesPerDay {
                // Random time throughout the day
                let hour = (entryIndex == 0) ? Int.random(in: 8...11) :
                          (entryIndex == 1) ? Int.random(in: 12...17) :
                          Int.random(in: 18...22)

                var components = calendar.dateComponents([.year, .month, .day], from: date)
                components.hour = hour
                components.minute = Int.random(in: 0...59)

                guard let entryDate = calendar.date(from: components) else { continue }

                // Random mood and note
                let mood = moods.randomElement() ?? .neutral
                let note = notes.randomElement() ?? ""

                // Create entry
                let entry = MoodEntry(
                    id: UUID(),
                    date: entryDate,
                    mood: mood,
                    note: note,
                    photoData: nil,
                    audioData: nil,
                    audioDuration: nil
                )

                dataManager.entries.append(entry)
            }
        }

        // Sort entries by date (newest first)
        dataManager.entries.sort { $0.date > $1.date }

        // Save to UserDefaults
        if let data = try? JSONEncoder().encode(dataManager.entries) {
            UserDefaults.standard.set(data, forKey: "moodEntries")
        }

        print("✅ Inserted mock data: \(dataManager.entries.count) total entries")
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataManager())
}
