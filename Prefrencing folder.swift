// Copyright 2025 Bobby529
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//     http://www.apache.org/licenses/LICENSE-2.0

import SwiftUI

struct PreferencesView: View {
    // existing prefs
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("enableMenuBar") private var enableMenuBar = true

    // Home Assistant settings
    @State private var baseURL: String = UserDefaults.standard.string(forKey: "haBaseURL") ?? "http://homeassistant.local:8123"
    @State private var token: String = UserDefaults.standard.string(forKey: "haToken") ?? ""
    @State private var pingResult: String = ""

    var body: some View {
        Form {
            Section(header: Text("General")) {
                Toggle("Launch at login", isOn: $launchAtLogin)
                Toggle("Show menu bar item", isOn: $enableMenuBar)
            }

            Section(header: Text("Home Assistant")) {
                TextField("Base URL (e.g. http://homeassistant.local:8123)", text: $baseURL)
                    .textFieldStyle(.roundedBorder)
                SecureField("Long-Lived Access Token", text: $token)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Button("Save") {
                        UserDefaults.standard.set(baseURL.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "haBaseURL")
                        UserDefaults.standard.set(token, forKey: "haToken")
                        pingResult = "Saved."
                    }
                    Button("Test Connection") {
                        Task {
                            do {
                                // Save before testing
                                UserDefaults.standard.set(baseURL.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "haBaseURL")
                                UserDefaults.standard.set(token, forKey: "haToken")
                                let code = try await HomeAssistantClient.shared.ping()
                                pingResult = (200...299).contains(code) ? "Connected (\(code))." : "Unexpected status \(code)."
                            } catch {
                                pingResult = error.localizedDescription
                            }
                        }
                    }
                    Spacer()
                    Text(pingResult).foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(width: 520)
    }
}
