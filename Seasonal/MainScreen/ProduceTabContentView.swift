//
//  ProduceTabContentView.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct ProduceTabContentView: View {

    @Environment(MainScreenState.self) private var state
    @Environment(ProduceStore.self) private var produceStore

    let tab: MainTabScreen.Tabs
    let searchText: String
    let onPeekFinished: (() async -> Void)?

    var body: some View {
        @Bindable var state = state

        switch tab {
        case .favourites, .search:
            ProduceList(
                produce: produceStore.favourites,
                parentTab: .favourites,
                selectedCategory: state.selectedCategory,
                searchText: searchText
            )
        case .months:
            PeriodPagerView<Months>(
                jumpToIndex: $state.jumpToMonthIndex,
                currentIndex: $state.currentMonthIndex,
                searchText: searchText,
                onPeekFinished: onPeekFinished
            )
        case .seasons:
            PeriodPagerView<Seasons>(
                jumpToIndex: $state.jumpToSeasonIndex,
                currentIndex: $state.currentSeasonIndex,
                searchText: searchText,
                onPeekFinished: onPeekFinished
            )
        }
    }
}
