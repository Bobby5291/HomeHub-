// Copyright 2025 Bobby529
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//     http://www.apache.org/licenses/LICENSE-2.0

import Foundation
import Combine
import IOKit.ps

final class PowerManager: ObservableObject {
    struct Snapshot {
        let onBattery: Bool
        let charging: Bool
        let percent: Int
        let timeRemainingMinutes: Int?
    }

    @Published private(set) var snapshot: Snapshot?

    private var timer: Timer?

    init() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.refresh()
        }
        if let t = timer {
            RunLoop.main.add(t, forMode: .common)
        }
    }

    deinit { timer?.invalidate() }

    func refresh() {
        guard
            let psInfo = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
            let list = IOPSCopyPowerSourcesList(psInfo)?.takeRetainedValue() as? [CFTypeRef],
            let ps = list.first,
            let descCF = IOPSGetPowerSourceDescription(psInfo, ps)?.takeUnretainedValue() as? [String: Any]
        else {
            snapshot = nil
            return
        }

        let current = (descCF[kIOPSCurrentCapacityKey as String] as? Int) ?? 0
        let maxCap = (descCF[kIOPSMaxCapacityKey as String] as? Int).map { Swift.max(1, $0) } ?? 100
        let pct = Int(round((Double(current) / Double(maxCap)) * 100.0))

        let powerState = (descCF[kIOPSPowerSourceStateKey as String] as? String) ?? kIOPSACPowerValue
        let onBattery = (powerState == kIOPSBatteryPowerValue)

        let isCharging: Bool = {
            if let isCharged = descCF[kIOPSIsChargedKey as String] as? Bool, isCharged { return false }
            if let flag = descCF[kIOPSIsChargingKey as String] as? Bool { return flag }
            return !onBattery
        }()

        var minutes: Int?
        if let t = descCF[kIOPSTimeToEmptyKey as String] as? Int, Double(t) != kIOPSTimeRemainingUnknown {
            minutes = t
        } else if let t = descCF[kIOPSTimeToFullChargeKey as String] as? Int, Double(t) != kIOPSTimeRemainingUnknown {
            minutes = t
        }

        snapshot = Snapshot(
            onBattery: onBattery,
            charging: isCharging,
            percent: pct,
            timeRemainingMinutes: minutes
        )
    }
}

