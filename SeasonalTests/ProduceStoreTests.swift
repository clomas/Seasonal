import XCTest
@testable import Seasonal

@available(iOS 26, *)
@MainActor
final class ProduceStoreTests: XCTestCase {

    func makeProduce(id: Int, name: String, category: ProduceCategory? = .fruit, months: [Months]? = nil, seasons: [Seasons]? = nil, liked: Bool = false) -> Produce {
        Produce(id: id, name: name, category: category, imageName: nil, description: nil, months: months, seasons: seasons, liked: liked)
    }

    func testFavouritesDerivedFromAllProduce() {
        let store = ProduceStore()

        let a = makeProduce(id: 1, name: "A", liked: true)
        let b = makeProduce(id: 2, name: "B", liked: false)

        store.loadMockData([a, b])

        let favourites = store.favourites
        XCTAssertEqual(favourites.count, 1)
        XCTAssertEqual(favourites.first?.id, 1)
    }

    func testByPeriodAndQuery() {
        let store = ProduceStore()

        let april = makeProduce(id: 1, name: "Apple", months: [.april])
        let may = makeProduce(id: 2, name: "Mango", months: [.may])

        store.loadMockData([april, may])

        var results = store.byPeriod(Months.april)
        XCTAssertEqual(results.count, 1)

        results = store.byPeriod(Months.april, query: "app")
        XCTAssertEqual(results.count, 1)

        results = store.byPeriod(Months.april, query: "no-match")
        XCTAssertEqual(results.count, 0)
    }

    func testToggleLikedUpdatesProduceAndFavourites() {
        let store = ProduceStore()
        let item = makeProduce(id: 1, name: "A", liked: false)
        store.loadMockData([item])

        store.toggleLiked(for: 1)

        // toggleLiked updates synchronously in-memory
        XCTAssertEqual(store.favourites.count, 1)
        XCTAssertTrue(store.allProduce.first(where: { $0.id == 1 })?.liked == true)
    }

    func testToggleLikedInvalidatesCachedDerivedLists() {
        let store = ProduceStore()
        let item = makeProduce(id: 1, name: "Apple", months: [.april], liked: false)
        store.loadMockData([item])

        // Prime the byPeriod/favourites caches with the un-liked state first,
        // mirroring how the UI reads them before a tap.
        XCTAssertEqual(store.byPeriod(Months.april).first?.liked, false)
        XCTAssertEqual(store.favourites.count, 0)

        store.toggleLiked(for: 1)

        // Re-reading must reflect the new state, not the stale cached arrays.
        XCTAssertEqual(store.byPeriod(Months.april).first?.liked, true)
        XCTAssertEqual(store.favourites.count, 1)
    }
}
