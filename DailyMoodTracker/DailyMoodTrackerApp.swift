//
//  DailyMoodTrackerApp.swift
//  DailyMoodTracker
//
//  Main app entry point with tab navigation and onboarding
//

import SwiftUI

@main
struct DailyMoodTrackerApp: App {
    @StateObject private var dataManager = DataManager()
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(dataManager)
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
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
        .tint(Color(hex: "667EEA")) // Accent color for selected tab
    }
}

#Preview {
    MainTabView()
        .environmentObject(DataManager())
}
