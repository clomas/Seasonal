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
        case .newSouthWales: "New South Wales"
        case .northernTerritory: "Northern Territory"
        case .queensland: "Queensland"
        case .southAustralia: "South Australia"
        case .tasmania: "Tasmania"
        case .victoria: "Victoria"
        case .westernAustralia: "Western Australia"
        case .noState, .act: "Error"
        }
    }

    /// The ACT has no produce data of its own.
    var isSelectable: Bool {
        self != .noState && self != .act
    }
}
