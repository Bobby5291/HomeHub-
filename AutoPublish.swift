// Copyright 2025 Bobby529
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//     http://www.apache.org/licenses/LICENSE-2.0

import Foundation
import Combine
import CoreLocation

/// Periodically sends local readings to Home Assistant using the REST API.
/// This does not create an "Integration" device; it creates/upserts entities in the state machine.
final class AutoPublisher {
    static let shared = AutoPublisher()

    private let power = PowerManager()
    private let location = LocationManager()
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Start location updates so we have a fix when publishing
        location.start()
        // Publish immediately, then every 120s
        Task { await self.publishAll() }
        timer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { [weak self] _ in
            Task { await self?.publishAll() }
        }
        if let t = timer { RunLoop.main.add(t, forMode: .common) }

        // Optional: also publish when power snapshot changes (on our 30s poll)
        power.$snapshot
            .compactMap { $0 }
            .debounce(for: .seconds(5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                Task { await self?.publishPowerOnly() }
            }
            .store(in: &cancellables)
    }

    deinit { timer?.invalidate() }

    @MainActor
    func publishAll() async {
        await publishPowerOnly()
        await publishLocationOnly()
    }

    @MainActor
    private func publishPowerOnly() async {
        guard let s = power.snapshot else { return }
        do {
            // Battery percent
            _ = try await HomeAssistantClient.shared.setState(
                entityId: "sensor.homehub_battery_percent",
                state: "\(s.percent)",
                attributes: [
                    "friendly_name": "HomeHub Battery",
                    "device_class": "battery",
                    "charging": s.charging,
                    "on_battery": s.onBattery
                ]
            )
            // Charging (as simple on/off text)
            _ = try await HomeAssistantClient.shared.setState(
                entityId: "sensor.homehub_charging",
                state: s.charging ? "on" : "off",
                attributes: [
                    "friendly_name": "HomeHub Charging",
                    "icon": s.charging ? "mdi:battery-charging" : "mdi:battery"
                ]
            )
            // On battery (on/off)
            _ = try await HomeAssistantClient.shared.setState(
                entityId: "sensor.homehub_on_battery",
                state: s.onBattery ? "on" : "off",
                attributes: [
                    "friendly_name": "HomeHub On Battery",
                    "icon": s.onBattery ? "mdi:battery-50" : "mdi:power-plug"
                ]
            )
            // Time remaining (minutes integer; may be nil)
            let mins = s.timeRemainingMinutes ?? -1
            _ = try await HomeAssistantClient.shared.setState(
                entityId: "sensor.homehub_time_remaining_min",
                state: "\(mins)",
                attributes: [
                    "friendly_name": "HomeHub Time Remaining (min)",
                    "unit_of_measurement": "min"
                ]
            )
        } catch {
            // Swallow errors; you can add logging if you like
            print("HA publish power failed: \(error)")
        }
    }

    @MainActor
    private func publishLocationOnly() async {
        guard let l = location.lastLocation else { return }
        do {
            let lat = l.coordinate.latitude
            let lon = l.coordinate.longitude
            _ = try await HomeAssistantClient.shared.setState(
                entityId: "sensor.homehub_location",
                state: String(format: "%.5f,%.5f", lat, lon),
                attributes: [
                    "friendly_name": "HomeHub Location",
                    "latitude": lat,
                    "longitude": lon,
                    "accuracy_m": Int(l.horizontalAccuracy)
                ]
            )
        } catch {
            print("HA publish location failed: \(error)")
        }
    }
}
