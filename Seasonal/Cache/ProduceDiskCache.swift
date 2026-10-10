//
//  ProduceDiskCache.swift
//  Seasonal
//
//  Created by Clint Thomas on 26/7/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Foundation

/// Keeps each region's catalogue indefinitely, so it's only downloaded once. Liked state isn't
/// trusted from here; it's always refreshed from CloudKit.
struct ProduceDiskCache: ProduceDiskCaching {

    /// Bump this when the produce data in CloudKit changes (new items, new icons) to discard every
    /// cached region once.
    static let currentCatalogueVersion = 1

    private struct Payload: Codable {
        let catalogueVersion: Int
        let produce: [Produce]
    }

    private let directory: URL
    private let catalogueVersion: Int

    init(
        directory: URL = .cachesDirectory.appending(path: "Produce", directoryHint: .isDirectory),
        catalogueVersion: Int = Self.currentCatalogueVersion
    ) {
        self.directory = directory
        self.catalogueVersion = catalogueVersion
    }

    func load(for location: StateLocation) -> [Produce]? {
        guard let data = try? Data(contentsOf: fileURL(for: location)),
              let payload = try? JSONDecoder().decode(Payload.self, from: data),
              payload.catalogueVersion == catalogueVersion
        else { return nil }
        return payload.produce
    }

    func save(_ produce: [Produce], for location: StateLocation) {
        let payload = Payload(catalogueVersion: catalogueVersion, produce: produce)
        guard let data = try? JSONEncoder().encode(payload) else { return }
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try? data.write(to: fileURL(for: location), options: .atomic)
    }

    private func fileURL(for location: StateLocation) -> URL {
        directory.appending(path: "\(location.rawValue).json", directoryHint: .notDirectory)
    }
}
