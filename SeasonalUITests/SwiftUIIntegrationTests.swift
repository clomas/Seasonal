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
}
