//
//  ProduceListEmptyState.swift
//  Seasonal
//
//  Created by Clint Thomas on 31/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct ProduceListEmptyState: View {

    let parentTab: MainTabScreen.Tabs
    let category: ProduceCategory
    let periodTitle: String?
    let searchText: String

    var body: some View {
        if searchText.isEmpty {
            ContentUnavailableView {
                Label {
                    Text(message)
                } icon: {
                    parentTab.emptyListIcon
                }
            }
        } else if let searchDescription {
            ContentUnavailableView {
                Label {
                    Text(Strings.EmptyState.noResults(for: searchText))
                } icon: {
                    Image.search
                }
            } description: {
                Text(searchDescription)
            }
        } else {
            ContentUnavailableView.search(text: searchText)
        }
    }

    var message: String {
        switch (categoryName, periodTitle) {
        case let (category?, period?): Strings.EmptyState.category(category, in: period)
        case let (category?, nil): Strings.EmptyState.favourites(in: category)
        case (nil, .some): Strings.EmptyState.period
        case (nil, nil): Strings.EmptyState.favourites
        }
    }

    var searchDescription: String? {
        switch (categoryName, periodTitle) {
        case let (category?, period?): Strings.EmptyState.searchCategory(category, in: period)
        case let (category?, nil): Strings.EmptyState.searchFavourites(in: category)
        case let (nil, period?): Strings.EmptyState.search(in: period)
        case (nil, nil): nil
        }
    }

    private var categoryName: String? {
        category == .all ? nil : category.title.localizedLowercase
    }
}
