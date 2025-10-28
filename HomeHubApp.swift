// Copyright 2025 Bobby529
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//     http://www.apache.org/licenses/LICENSE-2.0

import SwiftUI

@main
struct HomeHubApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        // Main window
        WindowGroup {
            ContentView()
                .environmentObject(appModel)
                .sheet(isPresented: $appModel.showAbout) {
                    AboutView()
                        .environmentObject(appModel)
                }
                // Start background publishing to Home Assistant (REST)
                .onAppear {
                    _ = AutoPublisher.shared     // automatic battery + location updates
                }
        }
        // App menu customisation (About)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About HomeHub") { appModel.showAbout = true }
            }
        }

        // Preferences / Settings (⌘,)
        Settings {
            PreferencesView()
                .environmentObject(appModel)
        }

        // Menu bar extra (macOS 13+)
        #if compiler(>=5.7)
        if #available(macOS 13, *) {
            MenuBarExtra("HomeHub", systemImage: "house.fill") {
                MenuBarView()
                    .environmentObject(appModel)
            }
        }
        #endif
    }
}
