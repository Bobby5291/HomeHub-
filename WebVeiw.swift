// Copyright 2025 Bobby529
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//     http://www.apache.org/licenses/LICENSE-2.0

import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    let url: URL
    let allowsBackForward: Bool

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        let web = WKWebView(frame: .zero, configuration: config)
        web.allowsBackForwardNavigationGestures = allowsBackForward
        web.customUserAgent = "HomeHub-macOS"
        return web
    }

    func updateNSView(_ web: WKWebView, context: Context) {
        guard web.url != url else { return }
        let req = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        web.load(req)
    }
}
