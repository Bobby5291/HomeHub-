// Copyright 2025 Bobby529
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//     http://www.apache.org/licenses/LICENSE-2.0

import SwiftUI

enum SidebarItem: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case map = "Map"
    case automations = "Automations"
    case logbook = "Logbook"
    case history = "History"
    case sensors = "Sensors"
    case notifications = "Notifications"
    case settings = "Settings"

    var id: String { rawValue }
    var systemImage: String {
        switch self {
        case .dashboard:    return "square.grid.2x2"
        case .map:          return "map"
        case .automations:  return "switch.2"
        case .logbook:      return "book"
        case .history:      return "chart.xyaxis.line"
        case .sensors:      return "gauge.with.dots.needle.67percent"
        case .notifications:return "bell"
        case .settings:     return "gearshape"
        }
    }
}

struct MainSidebar: View {
    @Binding var selection: SidebarItem

    var body: some View {
        List(SidebarItem.allCases, selection: $selection) { item in
            Label(item.rawValue, systemImage: item.systemImage)
                .tag(item)
        }
        .listStyle(.sidebar)
        .navigationTitle("HomeHub")
    }
}
