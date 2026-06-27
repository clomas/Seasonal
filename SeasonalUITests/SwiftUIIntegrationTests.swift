import XCTest

class SwiftUIIntegrationTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testMainTabViewExists() {
        let mainTab = app.otherElements["mainTabView"]
        XCTAssertTrue(mainTab.waitForExistence(timeout: 2))
    }

    func testTabBarContainsAllTabs() {
        let favourites = app.tabBars.buttons["Favourites"]
        let months = app.tabBars.buttons["Months"]
        let seasons = app.tabBars.buttons["Seasons"]

        XCTAssertTrue(favourites.exists)
        XCTAssertTrue(months.exists)
        XCTAssertTrue(seasons.exists)
    }

    func testFloatingSearchExpandsIntoField() {
        let searchButton = app.buttons["searchButton"]
        XCTAssertTrue(searchButton.waitForExistence(timeout: 2))
        searchButton.tap()

        let searchField = app.textFields["searchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
    }

    func testOpenCategoryFilterMenuShowsOptions() {
        let filterButton = app.buttons["filterByCategoryButton"]
        XCTAssertTrue(filterButton.waitForExistence(timeout: 2))
        filterButton.tap()

        let vegetables = app.buttons["Vegetables"]
        let fruit = app.buttons["Fruit"]
        let herbs = app.buttons["Herbs"]
        let all = app.buttons["All"]

        XCTAssertTrue(vegetables.waitForExistence(timeout: 2) || fruit.waitForExistence(timeout: 2) || herbs.waitForExistence(timeout: 2) || all.waitForExistence(timeout: 2))
    }

    // MARK: - Period filtering

    /// Chooses a location if the picker is showing, then waits for the main UI to load.
    private func passLocationPickerAndWaitForMain() {
        let state = app.buttons["New South Wales"]
        if state.waitForExistence(timeout: 4) {
            state.tap()
        }
        let mainTab = app.otherElements["mainTabView"]
        XCTAssertTrue(mainTab.waitForExistence(timeout: 20), "main UI did not load (CloudKit data?)")
    }

    /// The set of produce ids currently rendered anywhere in the app, read from the
    /// `produceRow_<id>` accessibility identifiers.
    private func visibleProduceIDs() -> Set<String> {
        let rows = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH 'produceRow_'"))
        var ids = Set<String>()
        for i in 0..<rows.count {
            ids.insert(rows.element(boundBy: i).identifier)
        }
        return ids
    }

    private func jump(toMonth title: String) {
        app.buttons["selectMonthButton"].tap()
        let item = app.buttons[title]
        XCTAssertTrue(item.waitForExistence(timeout: 3), "menu item \(title) missing")
        item.tap()
    }

    func testProduceUpdatesAcrossMonths() {
        passLocationPickerAndWaitForMain()

        app.buttons["tab-Months"].tap()
        XCTAssertTrue(app.scrollViews["produceList"].firstMatch.waitForExistence(timeout: 10))

        jump(toMonth: "January")
        let january = visibleProduceIDs()
        XCTAssertFalse(january.isEmpty, "January produce list is empty")

        jump(toMonth: "July")
        let july = visibleProduceIDs()
        XCTAssertFalse(july.isEmpty, "July produce list is empty")

        XCTAssertNotEqual(january, july, "produce did not change between January and July")
    }

    func testProduceUpdatesBetweenMonthsAndSeasons() {
        passLocationPickerAndWaitForMain()

        app.buttons["tab-Months"].tap()
        XCTAssertTrue(app.scrollViews["produceList"].firstMatch.waitForExistence(timeout: 10))
        let months = visibleProduceIDs()
        XCTAssertFalse(months.isEmpty, "Months produce list is empty")

        app.buttons["tab-Seasons"].tap()
        XCTAssertTrue(app.scrollViews["produceList"].firstMatch.waitForExistence(timeout: 10))
        let seasons = visibleProduceIDs()
        XCTAssertFalse(seasons.isEmpty, "Seasons produce list is empty")

        // Not necessarily disjoint, but the two should not be byte-identical sets if the
        // tab actually re-filters by season vs month.
        XCTAssertNotEqual(months, seasons, "produce did not change switching Months -> Seasons")
    }
}
