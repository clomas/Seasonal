//
//  ProduceDiskCache.swift
//  Seasonal
//
//  Created by Clint Thomas on 26/7/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Foundation

/// Persists the base produce catalogue (name/category/months/seasons) across app
/// launches. This data only changes with an app update, so it is keyed by app
/// version rather than a time-based expiry — liked state is intentionally not
/// trusted from this cache and is always refreshed from the CloudKit private
/// database (see `ProduceStore.fetchFromCloudKit`).
struct ProduceDiskCache {

    private struct Payload: Codable {
        let location: String
        let appVersion: String
        let produce: [Produce]
    }

    private let fileURL: URL
    private let appVersion: String

    init() {
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        fileURL = cachesDir.appendingPathComponent("produce_base_cache.json")
        appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }

    func load(for location: StateLocation) -> [Produce]? {
        guard let data = try? Data(contentsOf: fileURL),
              let payload = try? JSONDecoder().decode(Payload.self, from: data),
              payload.location == location.rawValue,
              payload.appVersion == appVersion
        else { return nil }
        return payload.produce
    }

    func save(_ produce: [Produce], for location: StateLocation) {
        let payload = Payload(location: location.rawValue, appVersion: appVersion, produce: produce)
        guard let data = try? JSONEncoder().encode(payload) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    func clear() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
