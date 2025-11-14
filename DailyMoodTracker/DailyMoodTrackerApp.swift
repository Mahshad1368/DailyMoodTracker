//
//  DailyMoodTrackerApp.swift
//  DailyMoodTracker
//
//  Main app entry point with tab navigation and onboarding
//

import SwiftUI
import UserNotifications

@main
struct DailyMoodTrackerApp: App {
    @StateObject private var dataManager = DataManager()
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(dataManager)
                    .onAppear {
                        // Clear badge when app opens
                        clearNotificationBadge()
                    }
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                // Clear badge when app becomes active (opened from notification or foreground)
                clearNotificationBadge()
            }
        }
    }

    private func clearNotificationBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                print("❌ Error clearing badge: \(error.localizedDescription)")
            } else {
                print("✅ Notification badge cleared")
            }
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    init() {
        // Configure tab bar appearance for dark theme
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.darkTheme.bgDarker)

        // Unselected tab color
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.darkTheme.textSecondary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.darkTheme.textSecondary)
        ]

        // Selected tab color
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.darkTheme.accent)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.darkTheme.accent)
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
        }
        .tint(Color.darkTheme.accent) // Purple accent for selected tab
    }
}

#Preview {
    MainTabView()
        .environmentObject(DataManager())
}
