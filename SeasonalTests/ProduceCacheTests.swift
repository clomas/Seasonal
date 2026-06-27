import XCTest
@testable import Seasonal

@available(iOS 26, *)
@MainActor
final class ProduceCacheTests: XCTestCase {

    func makeProduce(id: Int, name: String, category: ProduceCategory? = .fruit, months: [Months]? = nil, seasons: [Seasons]? = nil, liked: Bool = false) -> Produce {
        Produce(id: id, name: name, category: category, imageName: nil, description: nil, months: months, seasons: seasons, liked: liked)
    }

    func testAllProduceSortedAlphabetically() {
        let cache = ProduceCache()
        let banana = makeProduce(id: 1, name: "Banana")
        let apple = makeProduce(id: 2, name: "Apple")

        let result = cache.allProduce(from: [banana, apple])
        XCTAssertEqual(result.map { $0.name }, ["Apple", "Banana"])    }

    func testFavouritesReturnsOnlyLiked() {
        let cache = ProduceCache()
        let liked = makeProduce(id: 1, name: "A", liked: true)
        let notLiked = makeProduce(id: 2, name: "B", liked: false)

        let result = cache.favourites(from: [liked, notLiked])
        XCTAssertEqual(result.count, 1)
        XCTAssertTrue(result.allSatisfy { $0.liked == true })
    }

    func testByPeriodFiltersForMonths() {
        let cache = ProduceCache()
        let aprilProd = makeProduce(id: 1, name: "Apr", months: [.april])
        let mayProd = makeProduce(id: 2, name: "May", months: [.may])

        let result = cache.byPeriod(Months.april, from: [aprilProd, mayProd])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, 1)
    }

    func testByPeriodFiltersForSeasons() {
        let cache = ProduceCache()
        let summerProd = makeProduce(id: 1, name: "S", seasons: [.summer])
        let winterProd = makeProduce(id: 2, name: "W", seasons: [.winter])

        let result = cache.byPeriod(Seasons.summer, from: [summerProd, winterProd])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, 1)
    }

    func testSearchFiltersCaseInsensitive() {
        let cache = ProduceCache()
        let apple = makeProduce(id: 1, name: "Apple")
        let banana = makeProduce(id: 2, name: "Banana")

        let result = cache.search("app", from: [apple, banana])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Apple")
    }

    func testDerivedListsAreMemoisedUntilInvalidated() {
        let cache = ProduceCache()
        let liked = makeProduce(id: 1, name: "A", liked: true)

        // First call computes and caches the result.
        XCTAssertEqual(cache.favourites(from: [liked]).count, 1)

        // A later call with *different* input returns the cached value — the
        // argument is ignored until the cache is invalidated. This memoisation
        // is what masked stale `liked` state before the like-button fix.
        XCTAssertEqual(cache.favourites(from: []).count, 1)
    }

    func testInvalidateForcesRecomputeAcrossAllKeys() {
        let cache = ProduceCache()
        let liked = makeProduce(id: 1, name: "Apple", months: [.april], liked: true)

        // Prime every derived key.
        XCTAssertEqual(cache.favourites(from: [liked]).count, 1)
        XCTAssertEqual(cache.byPeriod(Months.april, from: [liked]).count, 1)
        XCTAssertEqual(cache.search("app", from: [liked]).count, 1)

        cache.invalidate()

        // After invalidation every key recomputes from the new (empty) input.
        XCTAssertEqual(cache.favourites(from: []).count, 0)
        XCTAssertEqual(cache.byPeriod(Months.april, from: []).count, 0)
        XCTAssertEqual(cache.search("app", from: []).count, 0)
    }
}
