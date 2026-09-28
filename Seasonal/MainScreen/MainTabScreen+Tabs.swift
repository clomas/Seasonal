//
//  MainTabScreen+Tabs.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
extension MainTabScreen {

    enum Tabs: Hashable {
        case favourites
        case months(Months)
        case seasons(Seasons)
        case search

        var title: String {
            switch self {
            case .favourites: Strings.Tab.favourites
            case .months(let month): month.title
            case .seasons(let season): season.title
            case .search: Strings.Tab.search
            }
        }

        var isSeasons: Bool {
            if case .seasons = self { true } else { false }
        }

        var emptyListIcon: Image {
            switch self {
            case .favourites: .favourites
            case .search: .search
            case .months, .seasons: .nothingToShow
            }
        }

        var emptyProduceListViewMessage: String {
            switch self {
            case .favourites: Strings.EmptyState.favourites
            case .search, .months, .seasons: Strings.EmptyState.period
            }
        }
    }
}
