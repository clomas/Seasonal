//
//  ComponentSnapshotTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SnapshotTesting
import SwiftUI
import XCTest
@testable import Seasonal

/// Reference images are recorded on the iPhone 17 Pro simulator (iOS 26); other devices will differ.
@available(iOS 26, *)
@MainActor
final class ComponentSnapshotTests: XCTestCase {

    private let rowWidth: CGFloat = 402
    private let fixedMonth: Months = .september

    func testLikedHeart() {
        assertComponentSnapshot(HStack { LikedHeartView(liked: false); LikedHeartView(liked: true) })
    }

    func testCurrentMonthIndicator() {
        assertComponentSnapshot(HStack {
            CurrentMonthIndicator(letter: "S", isInSeason: true, diameter: .capsuleRowHeight)
            CurrentMonthIndicator(letter: "S", isInSeason: false, diameter: .capsuleRowHeight)
        })
    }

    func testMonthsInSeasonCapsules() {
        assertComponentSnapshot(
            VStack {
                MonthsInSeasonCapsuleView(months: [.march, .april, .may], thisMonth: fixedMonth)
                MonthsInSeasonCapsuleView(months: [.december, .january, .september], thisMonth: fixedMonth)
                MonthsInSeasonCapsuleView(months: Months.allCases, thisMonth: fixedMonth)
            }
            .frame(width: rowWidth)
        )
    }

    func testProduceListRow() {
        let store = ProduceStore()
        assertComponentSnapshot(
            VStack(spacing: 0) {
                ProduceListRow(produce: previewProduce[0], showMonths: true, thisMonth: fixedMonth)
                ProduceListRow(produce: previewProduce[6], showMonths: false, thisMonth: fixedMonth)
            }
            .frame(width: rowWidth)
            .environmentObject(store)
        )
    }

    func testEmptyState() {
        assertComponentSnapshot(EmptyStateView(icon: .favourites, message: Strings.EmptyState.favourites))
    }

    func testAccentIconChip() {
        assertComponentSnapshot(AccentIconChip(systemImage: Symbol.location))
    }

    func testTintedGlassCapsuleButtons() {
        assertComponentSnapshot(VStack {
            TintedGlassCapsuleButton(label: StateLocation.victoria.fullName, systemImage: Symbol.location) {}
            TintedGlassCapsuleButton(label: Strings.Launch.tryAgain, systemImage: Symbol.retry, style: .prominent) {}
        })
    }

    func testFailureMessage() {
        assertComponentSnapshot(
            FailureMessageView(title: Strings.Launch.networkErrorTitle, message: Strings.Launch.networkErrorMessage) {}
                .frame(width: rowWidth)
        )
    }

    func testLocationPicker() {
        assertComponentSnapshot(LocationPickerView(onSelect: { _ in }, onFindLocationAgain: {}).frame(width: rowWidth))
    }

    func testAppLogo() {
        assertComponentSnapshot(AppLogo())
    }

    private func assertComponentSnapshot<V: View>(
        _ view: V,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        for style in [UIUserInterfaceStyle.light, .dark] {
            assertSnapshot(
                of: view.padding().background(Colour.background),
                as: .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: style)),
                named: style == .dark ? "dark" : "light",
                file: file,
                testName: testName,
                line: line
            )
        }
    }
}
