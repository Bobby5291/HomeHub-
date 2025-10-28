// Copyright 2025 Bobby529
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//     http://www.apache.org/licenses/LICENSE-2.0

import SwiftUI
import CoreLocation

struct LocationView: View {
    @StateObject private var loc = LocationManager()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Location").font(.headline)

            HStack(spacing: 12) {
                Button("Start") { loc.start() }
                Button("Stop")  { loc.stop() }
            }

            HStack {
                Text("Authorisation:")
                Text(loc.authorisation.rawValue.capitalized)
                    .fontWeight(.semibold)
            }

            if let l = loc.lastLocation {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Latitude:  \(String(format: "%.5f", l.coordinate.latitude))")
                    Text("Longitude: \(String(format: "%.5f", l.coordinate.longitude))")
                    if l.horizontalAccuracy >= 0 {
                        Text("Accuracy: ±\(Int(l.horizontalAccuracy)) m")
                            .foregroundStyle(.secondary)
                    }
                    Text("Updated:  \(l.timestamp.formatted(date: .omitted, time: .standard))")
                        .foregroundStyle(.secondary)
                }
                .accessibilityIdentifier("locationReadout")
            } else {
                Text("No fix yet.")
                    .foregroundStyle(.secondary)
            }

            if let e = loc.errorText {
                Text(e)
                    .foregroundStyle(.red)
            }
        }
        .padding()
    }
}
