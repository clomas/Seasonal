//
//  ProduceTabView.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

/// One stack per tab, never per pager page: a stack per page would each claim the search
/// field. The title stays inline because a collapsing title would track the horizontal pager.
@available(iOS 26, *)
struct ProduceTabView: View {

    @Environment(MainScreenState.self) private var state
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var isSearchPresented = false

    let tab: MainTabScreen.Tabs
    let isSearchable: Bool
    let onPeekFinished: (() async -> Void)?
    let onShowSettings: () -> Void

    var body: some View {
        @Bindable var state = state

        NavigationStack {
            ProduceTabContentView(tab: tab, searchText: searchText, onPeekFinished: onPeekFinished)
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
                        SettingsButton(action: onShowSettings)
                    }
                }
                .searchableIfPresent(
                    text: isSearchable ? $state.searchQuery : nil,
                    isPresented: $isSearchPresented,
                    placement: searchPlacement,
                    prompt: Strings.Search.prompt
                )
                .searchPresentationToolbarBehavior(.avoidHidingContent)
        }
        // `.searchTabSelection` only focuses a field that sits in the tab bar.
        .onAppear {
            isSearchPresented = isSearchable
        }
    }

    /// In a regular width the tab bar shares the navigation bar, which shrinks an automatic field
    /// to a second search button that the search tab can't open.
    private var searchPlacement: SearchFieldPlacement {
        horizontalSizeClass == .regular ? .navigationBarDrawer(displayMode: .always) : .automatic
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
