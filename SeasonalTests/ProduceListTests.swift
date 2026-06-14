import XCTest
@testable import Seasonal
import SwiftUI

@available(iOS 26, *)
final class ProduceListTests: XCTestCase {

    func makeProduce(id: Int, name: String, category: ProduceCategory? = .fruit, months: [Months]? = nil, seasons: [Seasons]? = nil, liked: Bool = false) -> Produce {
        Produce(id: id, name: name, category: category, imageName: nil, description: nil, months: months, seasons: seasons, liked: liked)
    }

    func testFilteredProduceReturnsAllWhenCategoryAll() {
        let p1 = makeProduce(id: 1, name: "Apple", category: .fruit)
        let p2 = makeProduce(id: 2, name: "Carrot", category: .vegetables)

        let view = ProduceList(produce: [p1, p2], selectedPeriodName: "test", parentTab: .favourites, selectedCategory: .constant(.all))

        XCTAssertEqual(view.filteredProduce.count, 2)
    }

    func testCategoryFiltering() {
        let p1 = makeProduce(id: 1, name: "Apple", category: .fruit)
        let p2 = makeProduce(id: 2, name: "Carrot", category: .vegetables)

        let view = ProduceList(produce: [p1, p2], selectedPeriodName: "test", parentTab: .favourites, selectedCategory: .constant(.vegetables))

        XCTAssertEqual(view.filteredProduce.count, 1)
        XCTAssertEqual(view.filteredProduce.first?.id, 2)
    }

    func testSearchFilteringIsCaseInsensitive() {
        let p1 = makeProduce(id: 1, name: "Apple", category: .fruit)
        let p2 = makeProduce(id: 2, name: "Carrot", category: .vegetables)

        let view = ProduceList(produce: [p1, p2], selectedPeriodName: "test", parentTab: .favourites, selectedCategory: .constant(.all), searchText: "app")

        XCTAssertEqual(view.filteredProduce.count, 1)
        XCTAssertEqual(view.filteredProduce.first?.id, 1)
    }

    func testEmptyListMessageForFavourites() {
        let view = ProduceList(produce: [], selectedPeriodName: "favourites", parentTab: .favourites, selectedCategory: .constant(.all))
        // The empty view text comes from `parentTab.emptyProduceListViewMessage` or a fallback string.
        XCTAssertNotNil(view.parentTab.emptyProduceListViewMessage)
    }
}
