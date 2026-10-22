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

    private let directory = URL.temporaryDirectory.appending(path: "produce-\(UUID().uuidString)", directoryHint: .isDirectory)
    private let cache: ProduceDiskCache

    init() {
        cache = ProduceDiskCache(directory: directory)
    }

    deinit {
        try? FileManager.default.removeItem(at: directory)
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

    @Test func eachRegionIsKeptSeparately() {
        cache.save([.fixture(id: 1, name: "Apple")], for: .victoria)
        cache.save([.fixture(id: 2, name: "Mango")], for: .queensland)

        #expect(cache.load(for: .victoria)?.map(\.id) == [1])
        #expect(cache.load(for: .queensland)?.map(\.id) == [2])
        #expect(cache.load(for: .tasmania) == nil)
    }

    @Test func bumpingTheCatalogueVersionDiscardsEveryRegion() {
        cache.save([.fixture(id: 1, name: "Apple")], for: .victoria)

        let bumped = ProduceDiskCache(directory: directory, catalogueVersion: ProduceDiskCache.currentCatalogueVersion + 1)

        #expect(bumped.load(for: .victoria) == nil)
    }

    @Test func unreadableFileMisses() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data("not json".utf8).write(to: directory.appending(path: "vic.json"))

        #expect(cache.load(for: .victoria) == nil)
    }
}
