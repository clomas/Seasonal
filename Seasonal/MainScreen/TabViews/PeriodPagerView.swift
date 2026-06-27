//
//  PeriodTabView.swift
//  Seasonal
//
//  Created by Clint Thomas on 19/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

protocol PeriodType: CaseIterable, Hashable where AllCases == [Self] {
    static var currentPeriod: Self { get }

    var title: String { get }
    var index: Int { get }
    var cacheKey: ProduceCacheKey { get }

    func contains(_ produce: Produce) -> Bool
}

@available(iOS 26, *)
struct PeriodPagerView<Period: PeriodType>: View {

    @EnvironmentObject var produceStore: ProduceStore

    let selectedTab: MainTabScreen.Tabs
    let searchQuery: String
    /// Whether the custom search bar is active; used to scope each period's title to the query.
    let isSearching: Bool

    private let periods: [PeriodItem]

    @Binding var selectedCategory: ProduceCategory
    /// Drives the top overlay buttons' visibility as the produce list scrolls.
    @Binding var chromeVisible: Bool
    /// Set by the (lifted) calendar button to scroll this pager to a period; reset to nil once handled.
    @Binding var jumpToIndex: Int?
    /// Reports the period index currently centred in the pager, so the jump menu can tick it.
    @Binding var currentIndex: Int

    var onPeekFinished: (() async -> Void)? = nil

    init(
        periods: [Period],
        selectedTab: MainTabScreen.Tabs,
        searchQuery: String,
        isSearching: Bool,
        selectedCategory: Binding<ProduceCategory>,
        chromeVisible: Binding<Bool> = .constant(true),
        jumpToIndex: Binding<Int?> = .constant(nil),
        currentIndex: Binding<Int> = .constant(0),
        onPeekFinished: (() async -> Void)? = nil
    ) {
        self.selectedTab = selectedTab
        self.searchQuery = searchQuery
        self.isSearching = isSearching
        self._selectedCategory = selectedCategory
        self._chromeVisible = chromeVisible
        self._jumpToIndex = jumpToIndex
        self._currentIndex = currentIndex
        self.onPeekFinished = onPeekFinished
        self.periods = periods.enumerated().map {
            PeriodItem(id: $0.offset, title: $0.element.title)
        }
    }

    var body: some View {
        PeriodScrollContainer(
            periods: periods,
            initialIndex: Period.currentPeriod.index,
            jumpToIndex: $jumpToIndex,
            currentIndex: $currentIndex,
            onPeekFinished: onPeekFinished
        ) { item in
            let period = Array(Period.allCases)[item.id]

            ProduceListNavigationView(title: cellTitle(for: period)) {
                ProduceList(
                    produce: produceStore.byPeriod(period, query: searchQuery),
                    selectedPeriodName: item.title,
                    parentTab: selectedTab,
                    selectedCategory: $selectedCategory,
                    chromeVisible: $chromeVisible
                )
            }
        }
    }

    private func cellTitle(for period: Period) -> String {
        isSearching && !searchQuery.isEmpty
            ? "\"\(searchQuery)\" in \(period.title)"
            : period.title
    }
}

#if DEBUG
@available(iOS 26, *)
#Preview {
    NavigationStack {
        PeriodPagerView<Months>(
            periods: Array(Months.allCases),
            selectedTab: MainTabScreen.Tabs.months(.april),
            searchQuery: "",
            isSearching: false,
            selectedCategory: Binding.constant(ProduceCategory.all)
        )
        .environmentObject(previewCoordinator)
        .environmentObject(previewCoordinator.produceStore)
        .environmentObject(FeatureToggleHelper())
    }
}
#endif
