//
//  BrowsingScreen.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

/// One stack per tab, never per pager page: a stack per page would each claim the search
/// field. The title stays inline because a collapsing title would track the horizontal pager.
@available(iOS 26, *)
struct BrowsingScreen: View {

    @Environment(MainScreenState.self) private var state

    let tab: MainTabScreen.Tabs
    let isSearchable: Bool
    let onPeekFinished: (() async -> Void)?
    let onShowInfo: () -> Void

    var body: some View {
        @Bindable var state = state

        NavigationStack {
            BrowsingContent(tab: tab, searchText: searchText, onPeekFinished: onPeekFinished)
                .navigationTitle(title)
                .toolbarTitleDisplayMode(.inline)
                .toolbarTitleMenu(isPresented: tab.hasPeriodPicker) {
                    switch tab {
                    case .months:
                        PeriodJumpPicker<Months>(
                            jumpToIndex: $state.jumpToMonthIndex,
                            title: Strings.Jump.toMonth,
                            currentIndex: state.currentMonthIndex
                        )
                    case .seasons:
                        PeriodJumpPicker<Seasons>(
                            jumpToIndex: $state.jumpToSeasonIndex,
                            title: Strings.Jump.toSeason,
                            currentIndex: state.currentSeasonIndex
                        )
                    case .favourites, .search:
                        EmptyView()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        CategoryFilterButton(selectedCategory: $state.selectedCategory)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        InfoButton(action: onShowInfo)
                    }
                }
                .searchableIfPresent(text: isSearchable ? $state.searchQuery : nil, prompt: Strings.Search.prompt)
                .searchPresentationToolbarBehavior(.avoidHidingContent)
        }
    }

    private var searchText: String {
        isSearchable ? state.searchQuery : ""
    }

    private var title: String {
        switch tab {
        case .months: Months.allCases[state.currentMonthIndex].title
        case .seasons: Seasons.allCases[state.currentSeasonIndex].title
        case .favourites, .search: MainTabScreen.Tabs.favourites.title
        }
    }
}
