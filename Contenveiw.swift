// Copyright 2025 Bobby529
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//     http://www.apache.org/licenses/LICENSE-2.0

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var selection: SidebarItem = .dashboard

    var body: some View {
        NavigationSplitView {
            MainSidebar(selection: $selection)
        } detail: {
            switch selection {
            case .dashboard:
                HAWebContainerView(path: .dashboard)
            case .map:
                HAWebContainerView(path: .map)
            case .automations:
                HAWebContainerView(path: .automations)
            case .logbook:
                HAWebContainerView(path: .logbook)
            case .history:
                HAWebContainerView(path: .history)
            case .sensors:
                SensorsView()
            case .notifications:
                NotificationsView()
            case .settings:
                SettingsPlaceholder()
            }
        }
        .toolbar {
            if #available(macOS 13, *) {
                ToolbarItem(placement: .automatic) {
                    // Correct modern syntax — no closure overload
                    SettingsLink {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
        }
    }
}

private struct SettingsPlaceholder: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Open Settings from the toolbar or press ⌘,")
            if #available(macOS 13, *) {
                // ✅ Simplified: correct label-based form
                SettingsLink {
                    Label("Open Settings", systemImage: "gearshape")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

