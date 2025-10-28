// Copyright 2025 Bobby529
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//     http://www.apache.org/licenses/LICENSE-2.0

import Foundation

// Simple REST client for Home Assistant. Reads base URL + token from UserDefaults.
final class HomeAssistantClient {
    static let shared = HomeAssistantClient()
    private init() {}

    // Keys used in PreferencesView
    private let urlKey = "haBaseURL"
    private let tokenKey = "haToken"

    struct HAError: Error, LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

    private func config() throws -> (base: URL, token: String) {
        guard
            let urlStr = UserDefaults.standard.string(forKey: urlKey)?.trimmingCharacters(in: .whitespacesAndNewlines),
            let url = URL(string: urlStr),
            let token = UserDefaults.standard.string(forKey: tokenKey),
            !token.isEmpty
        else {
            throw HAError(message: "Home Assistant URL or token not set.")
        }
        return (url, token)
    }

    /// Sets/updates an entity’s state via: POST /api/states/<entity_id>
    @discardableResult
    func setState(entityId: String, state: String, attributes: [String: Any] = [:]) async throws -> Int {
        let (base, token) = try config()
        let endpoint = base.appendingPathComponent("/api/states/\(entityId)")

        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        var body: [String: Any] = ["state": state]
        if !attributes.isEmpty { body["attributes"] = attributes }

        req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw HAError(message: "No HTTP response from Home Assistant.")
        }
        // 200 OK or 201 Created are both fine
        if (200...299).contains(http.statusCode) { return http.statusCode }

        let text = String(data: data, encoding: .utf8) ?? ""
        throw HAError(message: "HA error \(http.statusCode): \(text)")
    }

    /// Lightweight connectivity check: GET /api/
    @discardableResult
    func ping() async throws -> Int {
        let (base, token) = try config()
        let endpoint = base.appendingPathComponent("/api/")
        var req = URLRequest(url: endpoint)
        req.httpMethod = "GET"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (_, resp) = try await URLSession.shared.data(for: req)
        return (resp as? HTTPURLResponse)?.statusCode ?? -1
    }
}
