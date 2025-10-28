// Copyright 2025 Bobby529
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//     http://www.apache.org/licenses/LICENSE-2.0

import SwiftUI

struct HAWebContainerView: View {
    enum Path { case dashboard, map, automations, logbook, history }

    @State private var resolvedURL: URL?
    let path: Path

    private func pathComponent(for path: Path) -> String {
        switch path {
        case .dashboard:   return "/lovelace"
        case .map:         return "/map"
        case .automations: return "/config/automation/dashboard"
        case .logbook:     return "/logbook"
        case .history:     return "/history"
        }
    }

    var body: some View {
        Group {
            if let url = resolvedURL {
                WebView(url: url, allowsBackForward: true)
            } else {
                VStack(spacing: 8) {
                    ProgressView()
                    Text("Loading Home Assistant…").foregroundStyle(.secondary)
                }
            }
        }
        .onAppear {
            if let base = UserDefaults.standard.string(forKey: "haBaseURL"),
               let baseURL = URL(string: base) {
                resolvedURL = baseURL.appendingPathComponent(pathComponent(for: path))
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .navigation) { EmptyView() }
        }
    }

    private var title: String {
        switch path {
        case .dashboard:   return "Dashboard"
        case .map:         return "Map"
        case .automations: return "Automations"
        case .logbook:     return "Logbook"
        case .history:     return "History"
        }
    }
}
