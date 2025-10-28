// Copyright 2025 Bobby529
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//     http://www.apache.org/licenses/LICENSE-2.0

import SwiftUI

struct SensorsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Your existing views — keep them unchanged
                LocationView()
                Divider().padding(.vertical, 4)
                PowerView()
                // Optional: ClamshellView() if you added it
            }
            .padding()
        }
        .navigationTitle("Sensors")
    }
}
