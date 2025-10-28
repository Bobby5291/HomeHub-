// Copyright 2025 Bobby529
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//     http://www.apache.org/licenses/LICENSE-2.0

import SwiftUI
import Combine
import AppKit   // for NSApp

final class AppModel: ObservableObject {
    @Published var showAbout: Bool = false
    @Published var statusText: String = "Ready"

    func quitApp() {
        NSApp.terminate(nil)
    }

    func openPreferences() {
        // make sure window is brought forward
        NSApp.activate(ignoringOtherApps: true)
        if #available(macOS 13, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }
}
