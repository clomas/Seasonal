//
//  StateLocation.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

enum StateLocation: String, CaseIterable {

    case noState = "aus"
    case act
    case newSouthWales = "nsw"
    case northernTerritory = "nt"
    case queensland = "qld"
    case southAustralia = "sa"
    case tasmania = "tas"
    case victoria = "vic"
    case westernAustralia = "wa"

    static var selectable: [StateLocation] {
        allCases.filter(\.isSelectable)
    }

    var fullName: String {
        switch self {
        case .newSouthWales: Strings.State.newSouthWales
        case .northernTerritory: Strings.State.northernTerritory
        case .queensland: Strings.State.queensland
        case .southAustralia: Strings.State.southAustralia
        case .tasmania: Strings.State.tasmania
        case .victoria: Strings.State.victoria
        case .westernAustralia: Strings.State.westernAustralia
        case .noState: Strings.State.australia
        case .act: Strings.State.australianCapitalTerritory
        }
    }

    /// The ACT has no produce data of its own.
    var isSelectable: Bool {
        self != .noState && self != .act
    }
}
