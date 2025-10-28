// Copyright 2025 Bobby529
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//     http://www.apache.org/licenses/LICENSE-2.0

import SwiftUI

struct PowerView: View {
    @StateObject private var power = PowerManager()
    @State private var sendStatus: String = ""

    private func timeString(_ minutes: Int?) -> String {
        guard let m = minutes else { return "–" }
        let h = m / 60
        let mm = m % 60
        return h > 0 ? "\(h)h \(mm)m" : "\(mm)m"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Power").font(.headline)

            if let s = power.snapshot {
                HStack { Text("Battery:"); Text("\(s.percent)%").fontWeight(.semibold) }
                HStack { Text("State:"); Text(s.charging ? "Charging" : (s.onBattery ? "On Battery" : "On AC")).fontWeight(.semibold) }
                HStack { Text("Time remaining:"); Text(timeString(s.timeRemainingMinutes)).foregroundStyle(.secondary) }

                HStack(spacing: 12) {
                    Button("Refresh") { power.refresh() }
                    Button("Send to Home Assistant") {
                        Task {
                            do {
                                // entity ids: adjust to taste
                                let attrs: [String: Any] = [
                                    "friendly_name": "HomeHub Battery",
                                    "device_class": "battery",
                                    "charging": s.charging,
                                    "on_battery": s.onBattery
                                ]
                                _ = try await HomeAssistantClient.shared.setState(
                                    entityId: "sensor.homehub_battery_percent",
                                    state: "\(s.percent)",
                                    attributes: attrs
                                )
                                sendStatus = "Sent ✓"
                            } catch {
                                sendStatus = error.localizedDescription
                            }
                        }
                    }
                    Text(sendStatus).foregroundStyle(.secondary)
                }
                .padding(.top, 6)
            } else {
                HStack {
                    Text("No power data.").foregroundStyle(.secondary)
                    Button("Refresh") { power.refresh() }
                }
            }
        }
        .padding(.top, 4)
    }
}
