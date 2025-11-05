//
//  DailyMoodTrackerApp.swift
//  DailyMoodTracker
//
//  Main app entry point with tab navigation
//

import SwiftUI

@main
struct DailyMoodTrackerApp: App {
    @StateObject private var dataManager = DataManager()

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                HistoryView()
                    .tabItem {
                        Label("History", systemImage: "calendar")
                    }
            }
            .environmentObject(dataManager)
        }
    }
}
