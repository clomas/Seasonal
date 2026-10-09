//
//  ProduceStoreTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import CloudKit
import Testing
@testable import Seasonal

@MainActor
struct ProduceStoreTests {

    private let service = MockProduceProvider()
    private let diskCache = InMemoryProduceDiskCache()
    private let store: ProduceStore

    init() {
        store = ProduceStore(service: service, diskCache: diskCache)
    }

    // MARK: - Derived lists

    @Test func favouritesDerivedFromAllProduce() {
        store.loadMockData([
            .fixture(id: 1, name: "A", liked: true),
            .fixture(id: 2, name: "B", liked: false)
        ])

        #expect(store.favourites.map(\.id) == [1])
    }

    @Test func byPeriodReturnsOnlyThatPeriod() {
        store.loadMockData([
            .fixture(id: 1, name: "Apple", months: [.april]),
            .fixture(id: 2, name: "Mango", months: [.may])
        ])

        #expect(store.byPeriod(Months.april).map(\.id) == [1])
    }

    // MARK: - Liking

    @Test func toggleLikedUpdatesProduceAndFavourites() throws {
        store.loadMockData([.fixture(id: 1, name: "A", liked: false)])

        store.toggleLiked(for: 1)

        let item = try #require(store.allProduce.first { $0.id == 1 })
        #expect(item.liked)
        #expect(store.favourites.count == 1)
    }

    @Test func toggleLikedInvalidatesCachedDerivedLists() {
        store.loadMockData([.fixture(id: 1, name: "Apple", months: [.april], liked: false)])
        #expect(store.byPeriod(Months.april).first?.liked == false)
        #expect(store.favourites.isEmpty)

        store.toggleLiked(for: 1)

        #expect(store.byPeriod(Months.april).first?.liked == true)
        #expect(store.favourites.count == 1)
    }

    @Test(.tags(.networking)) func toggleLikedSyncsTheNewState() async throws {
        store.loadMockData([.fixture(id: 1, name: "A", liked: false)])

        try await #require(store.toggleLiked(for: 1)).value
        #expect(service.likeUpdates == [1: true])

        try await #require(store.toggleLiked(for: 1)).value
        #expect(service.likeUpdates == [1: false])
    }

    @Test func togglingUnknownProduceDoesNothing() {
        store.loadMockData([.fixture(id: 1, name: "A", liked: false)])

        #expect(store.toggleLiked(for: 99) == nil)
        #expect(store.favourites.isEmpty)
    }

    // MARK: - Fetching

    @Test(.tags(.networking)) func firstFetchDownloadsSortsAndSavesToDisk() async throws {
        service.produceResult = .success([.fixture(id: 1, name: "Pear"), .fixture(id: 2, name: "Apple")])

        try await store.fetchFromCloudKit(for: .victoria).get()

        #expect(service.produceRequests == [.victoria])
        #expect(store.allProduce.map(\.id) == [2, 1])
        #expect(diskCache.load(for: .victoria)?.map(\.id) == [1, 2])
    }

    @Test(.tags(.networking)) func diskCacheHitOnlyRefreshesLikes() async throws {
        let apple = Produce.fixture(id: 1, name: "Apple")
        diskCache.save([apple], for: .victoria)
        service.likesResult = [apple.withLiked(true)]

        try await store.fetchFromCloudKit(for: .victoria).get()

        #expect(service.produceRequests.isEmpty)
        #expect(service.likesRequests == [[1]])
        #expect(store.favourites.map(\.id) == [1])
    }

    @Test(.tags(.networking)) func refetchUsesTheMemoryCache() async throws {
        service.produceResult = .success([.fixture(id: 1, name: "Apple")])
        try await store.fetchFromCloudKit(for: .victoria).get()

        try await store.fetchFromCloudKit(for: .victoria).get()

        #expect(service.produceRequests.count == 1)
        #expect(store.allProduce.map(\.id) == [1])
    }

    @Test(.tags(.networking)) func failedFetchLeavesStoreAndDiskEmpty() async {
        service.produceResult = .failure(CKError(.networkFailure))

        let result = await store.fetchFromCloudKit(for: .victoria)

        let error = #expect(throws: CKError.self) { try result.get() }
        #expect(error?.code == .networkFailure)
        #expect(store.allProduce.isEmpty)
        #expect(diskCache.load(for: .victoria) == nil)
    }

    @Test(.tags(.networking)) func locationChangeDiscardsEverythingCached() async throws {
        service.produceResult = .success([.fixture(id: 1, name: "Apple")])
        try await store.fetchFromCloudKit(for: .victoria).get()

        store.prepareForLocationChange()

        #expect(store.allProduce.isEmpty)
        #expect(diskCache.load(for: .victoria) == nil)
        try await store.fetchFromCloudKit(for: .queensland).get()
        #expect(service.produceRequests == [.victoria, .queensland])
    }
}
