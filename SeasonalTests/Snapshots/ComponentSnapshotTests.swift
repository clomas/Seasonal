//
//  ComponentSnapshotTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SnapshotTesting
import SwiftUI
import Testing
@testable import Seasonal

/// Reference images are recorded on the iPhone 17 Pro simulator (iOS 26); other devices will differ.
@MainActor
@Suite(.tags(.snapshot))
struct ComponentSnapshotTests {

    private let rowWidth: CGFloat = 402
    private let fixedMonth: Months = .september

    @Test func likedHeart() {
        assertComponentSnapshot(HStack { LikedHeartView(liked: false); LikedHeartView(liked: true) })
    }

    @Test func currentMonthIndicator() {
        assertComponentSnapshot(HStack {
            CurrentMonthIndicator(letter: "S", isInSeason: true, diameter: .capsuleRowHeight)
            CurrentMonthIndicator(letter: "S", isInSeason: false, diameter: .capsuleRowHeight)
        })
    }

    @Test func monthsInSeasonCapsules() {
        assertComponentSnapshot(
            VStack {
                MonthsInSeasonCapsuleView(months: [.march, .april, .may], thisMonth: fixedMonth)
                MonthsInSeasonCapsuleView(months: [.december, .january, .september], thisMonth: fixedMonth)
                MonthsInSeasonCapsuleView(months: Months.allCases, thisMonth: fixedMonth)
            }
            .frame(width: rowWidth)
        )
    }

    @Test func produceListRow() {
        let store = ProduceStore()
        assertComponentSnapshot(
            VStack(spacing: 0) {
                ProduceListRow(produce: previewProduce[0], showMonths: true, thisMonth: fixedMonth)
                ProduceListRow(produce: previewProduce[6], showMonths: false, thisMonth: fixedMonth)
            }
            .frame(width: rowWidth)
            .environment(store)
        )
    }

    @Test func accentIconChip() {
        assertComponentSnapshot(AccentIconChip(systemImage: Symbol.location))
    }

    @Test func tintedGlassCapsuleButtons() {
        assertComponentSnapshot(VStack {
            TintedGlassCapsuleButton(label: StateLocation.victoria.fullName, systemImage: Symbol.location) {}
            TintedGlassCapsuleButton(label: Strings.Launch.tryAgain, systemImage: Symbol.retry, style: .prominent) {}
        })
    }

    @Test func failureMessage() {
        assertComponentSnapshot(
            FailureMessageView(title: Strings.Launch.networkErrorTitle, message: Strings.Launch.networkErrorMessage) {}
                .frame(width: rowWidth)
        )
    }

    @Test func locationPicker() {
        assertComponentSnapshot(LocationPickerView(onSelect: { _ in }, onFindLocationAgain: {}).frame(width: rowWidth))
    }

    @Test func appLogo() {
        assertComponentSnapshot(AppLogo())
    }

    private func assertComponentSnapshot<V: View>(
        _ view: V,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        for style in [UIUserInterfaceStyle.light, .dark] {
            assertSnapshot(
                of: view.padding().background(Colour.background),
                as: .image(layout: .sizeThatFits, traits: UITraitCollection(userInterfaceStyle: style)),
                named: style == .dark ? "dark" : "light",
                fileID: fileID,
                file: filePath,
                testName: testName,
                line: line,
                column: column
            )
        }
    }
}
