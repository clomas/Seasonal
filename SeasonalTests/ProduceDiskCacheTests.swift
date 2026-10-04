//
//  ProduceDiskCacheTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Foundation
import Testing
@testable import Seasonal

final class ProduceDiskCacheTests {

    private let fileURL = URL.temporaryDirectory.appending(path: "produce-\(UUID().uuidString).json")
    private let cache: ProduceDiskCache

    init() {
        cache = ProduceDiskCache(fileURL: fileURL)
    }

    deinit {
        try? FileManager.default.removeItem(at: fileURL)
    }

    @Test func roundTripsForTheSameLocation() throws {
        cache.save([.fixture(id: 1, name: "Apple", months: [.may])], for: .victoria)

        let loaded = try #require(cache.load(for: .victoria))

        #expect(loaded.map(\.id) == [1])
        #expect(loaded.first?.months == [.may])
    }

    @Test func emptyCacheMisses() {
        #expect(cache.load(for: .victoria) == nil)
    }

    @Test func differentLocationMisses() {
        cache.save([.fixture(id: 1, name: "Apple")], for: .victoria)

        #expect(cache.load(for: .queensland) == nil)
    }

    @Test func clearRemovesEverything() {
        cache.save([.fixture(id: 1, name: "Apple")], for: .victoria)

        cache.clear()

        #expect(cache.load(for: .victoria) == nil)
    }

    @Test func unreadableFileMisses() throws {
        try Data("not json".utf8).write(to: fileURL)

        #expect(cache.load(for: .victoria) == nil)
    }
}
