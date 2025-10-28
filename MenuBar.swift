// Copyright 2025 Bobby529
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//     http://www.apache.org/licenses/LICENSE-2.0

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HomeHub")
                .font(.headline)
            Text(appModel.statusText)
                .font(.subheadline)

            Divider()
            Button("Open HomeHub") {
                NSApp.activate(ignoringOtherApps: true)
            }
            Button("Preferences…") {
                NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
            }
            Divider()
            Button("Quit") {
                appModel.quitApp()
            }
        }
        .padding(12)
    }
}
