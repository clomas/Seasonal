import XCTest
@testable import Seasonal

@available(iOS 26, *)
final class MainTabScreenTests: XCTestCase {

    func testTabsTitlesAndMessages() {
        // Basic assertions for a few representative cases
        XCTAssertEqual(MainTabScreen.Tabs.favourites.title, "Favourites")
        XCTAssertEqual(MainTabScreen.Tabs.months(.april).title, "April")
        XCTAssertEqual(MainTabScreen.Tabs.seasons(.summer).title, "Summer")

        // Empty-message behaviour
        XCTAssertEqual(MainTabScreen.Tabs.favourites.emptyProduceListViewMessage, "No favourites selected")
        XCTAssertEqual(MainTabScreen.Tabs.months(.april).emptyProduceListViewMessage, "Nothing to display, try something else")
    }
}
    func testAllMonthCasesProduceCorrectTitles() {
        let sutJanuary = MainTabScreen.Tabs.months(.january)
        XCTAssertFalse(sutJanuary.title.isEmpty)

        let sutFebruary = MainTabScreen.Tabs.months(.february)
        XCTAssertFalse(sutFebruary.title.isEmpty)

        let sutMarch = MainTabScreen.Tabs.months(.march)
        XCTAssertFalse(sutMarch.title.isEmpty)

        let sutApril = MainTabScreen.Tabs.months(.april)
        XCTAssertFalse(sutApril.title.isEmpty)

        let sutMay = MainTabScreen.Tabs.months(.may)
        XCTAssertFalse(sutMay.title.isEmpty)

        let sutJune = MainTabScreen.Tabs.months(.june)
        XCTAssertFalse(sutJune.title.isEmpty)

        let sutJuly = MainTabScreen.Tabs.months(.july)
        XCTAssertFalse(sutJuly.title.isEmpty)

        let sutAugust = MainTabScreen.Tabs.months(.august)
        XCTAssertFalse(sutAugust.title.isEmpty)

        let sutSeptember = MainTabScreen.Tabs.months(.september)
        XCTAssertFalse(sutSeptember.title.isEmpty)

        let sutOctober = MainTabScreen.Tabs.months(.october)
        XCTAssertFalse(sutOctober.title.isEmpty)

        let sutNovember = MainTabScreen.Tabs.months(.november)
        XCTAssertFalse(sutNovember.title.isEmpty)

        let sutDecember = MainTabScreen.Tabs.months(.december)
        XCTAssertFalse(sutDecember.title.isEmpty)
    }

    func testAllSeasonCasesProduceCorrectTitles() {
        let sutSummer = MainTabScreen.Tabs.seasons(.summer)
        XCTAssertFalse(sutSummer.title.isEmpty)

        let sutAutumn = MainTabScreen.Tabs.seasons(.autumn)
        XCTAssertFalse(sutAutumn.title.isEmpty)

        let sutWinter = MainTabScreen.Tabs.seasons(.winter)
        XCTAssertFalse(sutWinter.title.isEmpty)

        let sutSpring = MainTabScreen.Tabs.seasons(.spring)
        XCTAssertFalse(sutSpring.title.isEmpty)
    }

