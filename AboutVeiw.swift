// Copyright 2025 Bobby529
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//     http://www.apache.org/licenses/LICENSE-2.0


import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 12) {
            Text("HomeHub")
                .font(.title)
                .fontWeight(.semibold)

            Text("A native macOS app starter.")
                .foregroundStyle(.secondary)

            Button("Close") { appModel.showAbout = false }
                .keyboardShortcut(.cancelAction)
        }
        .padding()
        .frame(width: 360)
    }
}
