//
//  ProduceDiskCache.swift
//  Seasonal
//
//  Created by Clint Thomas on 26/7/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Foundation

/// The base catalogue only changes with an app update, so it's keyed by app version.
/// Liked state isn't trusted from here; it's always refreshed from CloudKit.
struct ProduceDiskCache {

    private struct Payload: Codable {
        let location: String
        let appVersion: String
        let produce: [Produce]
    }

    private let fileURL = FileManager.default
        .urls(for: .cachesDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("produce_base_cache.json")
    private let appVersion = Bundle.main.shortVersion ?? "0"

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
