//
//  SettingsView.swift
//  DailyMoodTracker
//
//  App settings and preferences - No statistics, only configuration
//

import SwiftUI

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
    @State private var showNotesField: Bool = UserDefaults.standard.bool(forKey: "showNotesField")
    @State private var requireNote: Bool = UserDefaults.standard.bool(forKey: "requireNote")

    // Alerts
    @State private var showingDeleteAlert = false
    @State private var showingExportSheet = false
    @State private var showingIconPicker = false

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
                                    .onChange(of: userName) { _, newValue in
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
                                    .onChange(of: dailyReminderEnabled) { _, newValue in
                                        UserDefaults.standard.set(newValue, forKey: "dailyReminderEnabled")
                                        // TODO: Schedule/cancel notifications
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
                                    .onChange(of: reminderTime) { _, newValue in
                                        UserDefaults.standard.set(newValue, forKey: "reminderTime")
                                        // TODO: Reschedule notification
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

                            // App Icon Picker
                            Button(action: { showingIconPicker = true }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("App Icon")
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundColor(.white)

                                        Text("Choose your favorite icon")
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(.white.opacity(0.6))
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }

                            Divider()
                                .background(Color.white.opacity(0.2))

                            // Dark Mode Toggle (placeholder - iOS handles this system-wide)
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Time-based Gradients")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(.white)

                                    Text("Home screen changes throughout the day")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.white.opacity(0.6))
                                }

                                Spacer()

                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "667EEA"))
                            }
                        }
                    }
                    .padding(.horizontal, 25)

                    // Mood Logging Section
                    DarkGlassCard(padding: 20) {
                        VStack(alignment: .leading, spacing: 20) {
                            Label("Mood Logging", systemImage: "pencil")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.white)

                            // Show Notes Field Toggle
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Show Notes Field")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(.white)

                                    Text("Display note input when logging")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.white.opacity(0.6))
                                }

                                Spacer()

                                Toggle("", isOn: $showNotesField)
                                    .labelsHidden()
                                    .tint(Color(hex: "667EEA"))
                                    .onChange(of: showNotesField) { _, newValue in
                                        UserDefaults.standard.set(newValue, forKey: "showNotesField")
                                    }
                            }

                            Divider()
                                .background(Color.white.opacity(0.2))

                            // Require Note Toggle
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Require Note")
                                        .font(.system(.subheadline, design: .rounded))
                                        .foregroundColor(.white)

                                    Text("Make notes mandatory for each entry")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.white.opacity(0.6))
                                }

                                Spacer()

                                Toggle("", isOn: $requireNote)
                                    .labelsHidden()
                                    .tint(Color(hex: "667EEA"))
                                    .disabled(!showNotesField)
                                    .onChange(of: requireNote) { _, newValue in
                                        UserDefaults.standard.set(newValue, forKey: "requireNote")
                                    }
                            }
                            .opacity(showNotesField ? 1.0 : 0.5)
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
        .sheet(isPresented: $showingIconPicker) {
            AppIconPickerView()
        }
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

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - App Icon Picker View
struct AppIconPickerView: View {
    @Environment(\.dismiss) var dismiss

    let icons = [
        ("Default", nil),
        ("Happy", "AppIcon-Happy"),
        ("Neutral", "AppIcon-Neutral"),
        ("Sad", "AppIcon-Sad"),
        ("Angry", "AppIcon-Angry"),
        ("Sleepy", "AppIcon-Sleepy")
    ]

    @State private var selectedIcon: String? = UIApplication.shared.alternateIconName

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A1A2E")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        Text("Choose Your App Icon")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 20)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(icons, id: \.1) { icon in
                                AppIconOption(
                                    name: icon.0,
                                    iconName: icon.1,
                                    isSelected: selectedIcon == icon.1
                                ) {
                                    setAppIcon(icon.1)
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                    }
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

    private func setAppIcon(_ iconName: String?) {
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("Error setting icon: \(error.localizedDescription)")
            } else {
                selectedIcon = iconName
            }
        }
    }
}

struct AppIconOption: View {
    let name: String
    let iconName: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon preview
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "app.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color(hex: "667EEA") : Color.clear, lineWidth: 3)
                    )

                Text(name)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "667EEA"))
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataManager())
}
