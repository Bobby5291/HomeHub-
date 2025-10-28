// Copyright 2025 Bobby529
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//     http://www.apache.org/licenses/LICENSE-2.0

import SwiftUI

struct NotificationsView: View {
    @State private var note = "Hello from HomeHub"
    @State private var info = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Local Notification (Preview)").font(.headline)
            TextField("Message", text: $note)
            HStack {
                Button("Show Test Notification") {
                    info = "Queued local notification (implement UNUserNotificationCenter next)."
                }
                Spacer()
                Text(info).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Notifications")
    }
}
