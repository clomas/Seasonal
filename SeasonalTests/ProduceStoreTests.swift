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
            .fixture(id: 1, name: "A", isFavourite: true),
            .fixture(id: 2, name: "B", isFavourite: false)
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

    @Test func toggleFavouriteUpdatesProduceAndFavourites() throws {
        store.loadMockData([.fixture(id: 1, name: "A", isFavourite: false)])

        store.toggleFavourite(for: 1)

        let item = try #require(store.allProduce.first { $0.id == 1 })
        #expect(item.isFavourite)
        #expect(store.favourites.count == 1)
    }

    @Test func toggleFavouriteInvalidatesCachedDerivedLists() {
        store.loadMockData([.fixture(id: 1, name: "Apple", months: [.april], isFavourite: false)])
        #expect(store.byPeriod(Months.april).first?.isFavourite == false)
        #expect(store.favourites.isEmpty)

        store.toggleFavourite(for: 1)

        #expect(store.byPeriod(Months.april).first?.isFavourite == true)
        #expect(store.favourites.count == 1)
    }

    @Test(.tags(.networking)) func toggleFavouriteSyncsTheNewState() async throws {
        store.loadMockData([.fixture(id: 1, name: "A", isFavourite: false)])

        try await #require(store.toggleFavourite(for: 1)).value
        #expect(service.favouriteUpdates == [1: true])

        try await #require(store.toggleFavourite(for: 1)).value
        #expect(service.favouriteUpdates == [1: false])
    }

    @Test func togglingUnknownProduceDoesNothing() {
        store.loadMockData([.fixture(id: 1, name: "A", isFavourite: false)])

        #expect(store.toggleFavourite(for: 99) == nil)
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

    @Test(.tags(.networking)) func diskCacheHitOnlyRefreshesFavourites() async throws {
        let apple = Produce.fixture(id: 1, name: "Apple")
        diskCache.save([apple], for: .victoria)
        service.favouritesResult = [apple.withFavourite(true)]

        try await store.fetchFromCloudKit(for: .victoria).get()

        #expect(service.produceRequests.isEmpty)
        #expect(service.favouritesRequests == [[1]])
        #expect(store.favourites.map(\.id) == [1])
    }

    @Test(.tags(.networking)) func refetchingTheLoadedLocationIsFree() async throws {
        service.produceResult = .success([.fixture(id: 1, name: "Apple")])
        try await store.fetchFromCloudKit(for: .victoria).get()

        try await store.fetchFromCloudKit(for: .victoria).get()

        #expect(service.produceRequests.count == 1)
        #expect(service.favouritesRequests.isEmpty)
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

    @Test(.tags(.networking)) func switchingBackToALoadedRegionUsesItsCache() async throws {
        service.produceResult = .success([.fixture(id: 1, name: "Apple")])
        try await store.fetchFromCloudKit(for: .victoria).get()
        service.produceResult = .success([.fixture(id: 2, name: "Mango")])
        try await store.fetchFromCloudKit(for: .queensland).get()

        service.favouritesResult = [.fixture(id: 1, name: "Apple")]
        try await store.fetchFromCloudKit(for: .victoria).get()

        #expect(service.produceRequests == [.victoria, .queensland])
        #expect(service.favouritesRequests == [[1]])
        #expect(store.allProduce.map(\.id) == [1])
    }

    @Test(.tags(.networking)) func failedLocationChangeKeepsTheCurrentProduce() async throws {
        service.produceResult = .success([.fixture(id: 1, name: "Apple")])
        try await store.fetchFromCloudKit(for: .victoria).get()
        service.produceResult = .failure(CKError(.networkFailure))

        let result = await store.fetchFromCloudKit(for: .queensland)

        #expect(throws: CKError.self) { try result.get() }
        #expect(store.allProduce.map(\.id) == [1])
    }
}
