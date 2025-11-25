//
//  SettingsView.swift
//  DailyMoodTracker
//
//  App settings and preferences - No statistics, only configuration
//

import SwiftUI
import UserNotifications
import PhotosUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.dismiss) var dismiss
    @AppStorage("darkModeEnabled") private var isDarkMode: Bool = true

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
    @State private var appearanceMode: AppearanceMode = {
        let isDark = UserDefaults.standard.bool(forKey: "darkModeEnabled")
        return isDark ? .dark : .light
    }()

    enum AppearanceMode: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
    }

    private var theme: ThemeColors {
        isDarkMode ? Color.darkTheme : Color.lightTheme
    }

    // Profile picture
    @State private var profilePictureData: Data? = UserDefaults.standard.data(forKey: "profilePicture")
    @State private var selectedPhotoItem: PhotosPickerItem?

    // Alerts
    @State private var showingDeleteAlert = false
    @State private var showingExportSheet = false

    var body: some View {
        ZStack {
            // Dynamic theme gradient background
            DarkThemeBackground(isDark: isDarkMode)

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundColor(theme.textPrimary)
                        }

                        Text("Settings")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(theme.textPrimary)

                        Spacer()
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)

                    // User Profile Section
                    DarkThemeCard(padding: 20, isDark: isDarkMode) {
                        VStack(spacing: 20) {
                            // Profile Picture
                            ZStack(alignment: .topTrailing) {
                                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                    ZStack {
                                        if let profilePictureData = profilePictureData,
                                           let uiImage = UIImage(data: profilePictureData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke((isDarkMode ? Color.white : Color.gray).opacity(0.3), lineWidth: 3)
                                                )
                                        } else {
                                            Circle()
                                                .fill((isDarkMode ? Color.white : Color.gray).opacity(0.1))
                                                .frame(width: 100, height: 100)
                                                .overlay(
                                                    Text("👤")
                                                        .font(.system(size: 50))
                                                )
                                        }

                                        // Camera icon overlay
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(theme.textPrimary)
                                                    .padding(8)
                                                    .background(Circle().fill(Color(hex: "667EEA")))
                                            }
                                        }
                                        .frame(width: 100, height: 100)
                                    }
                                }
                                .onChange(of: selectedPhotoItem) { newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                            profilePictureData = data
                                            UserDefaults.standard.set(data, forKey: "profilePicture")
                                        }
                                    }
                                }

                                // Delete button - only show when profile photo exists
                                if profilePictureData != nil {
                                    Button(action: {
                                        // Remove profile photo
                                        profilePictureData = nil
                                        UserDefaults.standard.removeObject(forKey: "profilePicture")
                                        selectedPhotoItem = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(.red)
                                            .background(
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 20, height: 20)
                                            )
                                    }
                                    .offset(x: 8, y: -8)
                                }
                            }

                            VStack(spacing: 12) {
                                Text("Your Name")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(theme.textSecondary)

                                TextField("Enter your name", text: $userName)
                                    .textFieldStyle(.plain)
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(theme.textPrimary)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .background((isDarkMode ? Color.white : Color.gray).opacity(0.1))
                                    .cornerRadius(12)
                                    .onChange(of: userName) { newValue in
                                        UserDefaults.standard.set(newValue, forKey: "userName")
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 25)

                    // Notifications Section
                    DarkThemeCard(padding: 20, isDark: isDarkMode) {
                        VStack(alignment: .leading, spacing: 20) {
                            Label("Notifications", systemImage: "bell.fill")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(theme.textPrimary)

                            // Daily Reminder Toggle
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Daily Reminder")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(theme.textPrimary)

                                    Text("Get reminded to log your mood")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(theme.textSecondary)
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
                                        .foregroundColor(theme.textPrimary)

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

                                #if DEBUG
                                // Test Notification Button (Debug Only)
                                Button(action: {
                                    notificationManager.sendTestNotification()
                                }) {
                                    HStack {
                                        Image(systemName: "bell.badge")
                                            .foregroundColor(Color(hex: "667EEA"))
                                        Text("Send Test Notification")
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundColor(theme.textPrimary)
                                        Spacer()
                                        Text("5s")
                                            .font(.caption)
                                            .foregroundColor(theme.textSecondary)
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(Color(hex: "667EEA").opacity(0.1))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 8)
                                #endif
                            }
                        }
                    }
                    .padding(.horizontal, 25)

                    // Appearance Section
                    DarkThemeCard(padding: 20, isDark: isDarkMode) {
                        VStack(alignment: .leading, spacing: 20) {
                            Label("Appearance", systemImage: "paintbrush.fill")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(theme.textPrimary)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Theme")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(theme.textPrimary)

                                // Light and Dark Mode Options
                                HStack(spacing: 12) {
                                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                                        Button(action: {
                                            appearanceMode = mode
                                            UserDefaults.standard.set(mode == .dark, forKey: "darkModeEnabled")
                                            isDarkMode = (mode == .dark)
                                        }) {
                                            HStack(spacing: 8) {
                                                Image(systemName: mode == .light ? "sun.max.fill" : "moon.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(appearanceMode == mode ? theme.textPrimary : theme.textSecondary)

                                                Text(mode.rawValue)
                                                    .font(.system(.subheadline, design: .rounded))
                                                    .fontWeight(appearanceMode == mode ? .semibold : .regular)
                                                    .foregroundColor(appearanceMode == mode ? theme.textPrimary : theme.textSecondary)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(appearanceMode == mode ? theme.accent : (isDarkMode ? Color.white : Color.gray).opacity(0.1))
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 25)

                    // Data Management Section
                    DarkThemeCard(padding: 20, isDark: isDarkMode) {
                        VStack(alignment: .leading, spacing: 20) {
                            Label("Data Management", systemImage: "externaldrive.fill")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(theme.textPrimary)

                            // Export Data Button
                            Button(action: { showingExportSheet = true }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Export Data")
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundColor(theme.textPrimary)

                                        Text("Save your mood history")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(theme.textSecondary)
                                    }

                                    Spacer()

                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(Color(hex: "667EEA"))
                                }
                            }

                            Divider()
                                .background((isDarkMode ? Color.white : Color.gray).opacity(0.2))

                            // Delete All Data Button
                            Button(action: { showingDeleteAlert = true }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Delete All Data")
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundColor(.red.opacity(0.9))

                                        Text("Permanently remove all entries")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(theme.textSecondary)
                                    }

                                    Spacer()

                                    Image(systemName: "trash")
                                        .foregroundColor(.red.opacity(0.7))
                                }
                            }

                            #if DEBUG
                            Divider()
                                .background((isDarkMode ? Color.white : Color.gray).opacity(0.2))

                            // Insert Mock Data Button (Debug Only)
                            Button(action: insertMockData) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Insert Mock Data")
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundColor(Color(hex: "667EEA"))

                                        Text("Add 3 months of test entries (debug)")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(theme.textSecondary)
                                    }

                                    Spacer()

                                    Image(systemName: "wand.and.stars")
                                        .foregroundColor(Color(hex: "667EEA"))
                                }
                            }

                            Divider()
                                .background((isDarkMode ? Color.white : Color.gray).opacity(0.2))

                            // Reset Onboarding Button (Debug Only)
                            Button(action: resetOnboarding) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Reset Onboarding")
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundColor(Color(hex: "667EEA"))

                                        Text("View onboarding pages again (debug)")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(theme.textSecondary)
                                    }

                                    Spacer()

                                    Image(systemName: "arrow.counterclockwise")
                                        .foregroundColor(Color(hex: "667EEA"))
                                }
                            }
                            #endif
                        }
                    }
                    .padding(.horizontal, 25)

                    // About Section
                    DarkThemeCard(padding: 20, isDark: isDarkMode) {
                        VStack(alignment: .leading, spacing: 20) {
                            Label("About", systemImage: "info.circle.fill")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(theme.textPrimary)

                            // Version
                            HStack {
                                Text("Version")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(theme.textPrimary)

                                Spacer()

                                Text("1.0.0")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(theme.textSecondary)
                            }

                            Divider()
                                .background((isDarkMode ? Color.white : Color.gray).opacity(0.2))

                            // Privacy Policy
                            Button(action: {
                                if let url = URL(string: "https://mahshad1368.github.io/DailyMoodTracker/privacy-policy.html") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Text("Privacy Policy")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(theme.textPrimary)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(theme.textSecondary)
                                }
                            }

                            Divider()
                                .background((isDarkMode ? Color.white : Color.gray).opacity(0.2))

                            // Rate App
                            Button(action: {
                                // Open App Store rating
                            }) {
                                HStack {
                                    Text("Rate This App")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(theme.textPrimary)

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
            ExportDataView(entries: dataManager.entries, isDark: isDarkMode)
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
        // Use NotificationManager to schedule with actionable buttons
        notificationManager.scheduleDailyReminder(at: time)
    }

    private func cancelDailyNotification() {
        // Use NotificationManager to cancel
        notificationManager.cancelDailyReminder()
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

    private func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        print("✅ Onboarding reset - restart app to view onboarding pages")
    }
}

// MARK: - Export Data View
struct ExportDataView: View {
    let entries: [MoodEntry]
    let isDark: Bool
    @Environment(\.dismiss) var dismiss

    private var theme: ThemeColors {
        isDark ? Color.darkTheme : Color.lightTheme
    }

    var body: some View {
        NavigationView {
            ZStack {
                (isDark ? Color.darkTheme.bgDarker : Color.lightTheme.bgLight)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Export Your Data")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(theme.textPrimary)

                    Text("Choose how you'd like to export your mood history")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(theme.textSecondary)
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
                            .foregroundColor(theme.textPrimary)
                            .padding()
                            .background((isDark ? Color.white : Color.gray).opacity(0.1))
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
                            .foregroundColor(theme.textPrimary)
                            .padding()
                            .background((isDark ? Color.white : Color.gray).opacity(0.1))
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
                    .foregroundColor(theme.textPrimary)
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
}

#Preview {
    SettingsView()
        .environmentObject(DataManager())
}
