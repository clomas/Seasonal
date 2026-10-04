//
//  LocationTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Testing
@testable import Seasonal

struct LocationTests {

    private let manager = LocationInformationManager()

    @Test func selectableStatesExcludeNoStateAndACT() {
        let selectable = StateLocation.selectable

        #expect(selectable.contains(.noState) == false)
        #expect(selectable.contains(.act) == false)
        #expect(selectable.count == StateLocation.allCases.count - 2)
    }

    @Test(arguments: StateLocation.selectable)
    func selectableStateHasARealName(_ state: StateLocation) {
        #expect(state.fullName != "Error")
    }

    @Test(arguments: StateLocation.selectable)
    func australianStateIsParsedFromItsAbbreviation(_ state: StateLocation) {
        #expect(manager.state(from: state.rawValue.uppercased(), country: Constants.straya) == state)
        #expect(manager.state(from: state.rawValue, country: Constants.straya) == state)
    }

    @Test func actUsesNewSouthWales() {
        #expect(manager.state(from: "ACT", country: Constants.straya) == .newSouthWales)
    }

    @Test func outsideAustraliaHasNoState() {
        #expect(manager.state(from: "CA", country: "United States") == .noState)
    }

    @Test(arguments: [nil, "Somewhere"])
    func unknownOrMissingAreaHasNoState(_ area: String?) {
        #expect(manager.state(from: area, country: Constants.straya) == .noState)
    }
}
