//
//  InfoUITests.swift
//  SeasonalUITests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import XCTest

@available(iOS 26, *)
final class InfoUITests: SeasonalUITestCase {

    private let brightScreen = 0.6
    private let darkScreen = 0.4
    private let appearanceSettleTime: TimeInterval = 1

    func testInfoSheetOpensAndCloses() throws {
        try launch()

        app.buttons["settingsButton"].tap()

        let sheet = app.navigationBars["Seasonal"]
        XCTAssertTrue(sheet.waitForExistence(timeout: elementTimeout))
        XCTAssertTrue(app.staticTexts["Produce location"].exists)

        sheet.buttons["closeInfoButton"].tap()

        XCTAssertTrue(sheet.waitForNonExistence(timeout: elementTimeout))
    }

    func testAppearanceChangesWhileSettingsAreOpen() throws {
        try launch()
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.navigationBars["Seasonal"].waitForExistence(timeout: elementTimeout))
        defer { choose("Automatic", in: "Mode") }

        choose("Light", in: "Mode")
        XCTAssertGreaterThan(screenBrightness(), brightScreen)

        choose("Dark", in: "Mode")
        XCTAssertLessThan(screenBrightness(), darkScreen)
    }

    private func choose(_ option: String, in picker: String) {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", picker)).firstMatch.tap()
        app.buttons[option].firstMatch.tap()
        Thread.sleep(forTimeInterval: appearanceSettleTime)
    }

    /// Average luminance (0–1), from the screenshot scaled down to a single pixel.
    private func screenBrightness() -> Double {
        guard let image = XCUIScreen.main.screenshot().image.cgImage else { return 0 }
        var pixel = [UInt8](repeating: 0, count: 4)
        let context = CGContext(
            data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        context?.interpolationQuality = .medium
        context?.draw(image, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        return (0.299 * Double(pixel[0]) + 0.587 * Double(pixel[1]) + 0.114 * Double(pixel[2])) / 255
    }
}
