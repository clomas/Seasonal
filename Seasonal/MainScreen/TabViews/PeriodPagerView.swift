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

    @EnvironmentObject var appCoordinator: AppCoordinator

    let selectedTab: MainTabScreen.Tabs
    let searchQuery: String
    let isSearching: Bool

    @Binding var selectedCategory: ProduceCategory

    var onPeekFinished: (() async -> Void)? = nil

    private let periods: [PeriodItem]

    init(
        periods: [Period],
        selectedTab: MainTabScreen.Tabs,
        searchQuery: String,
        isSearching: Bool,
        selectedCategory: Binding<ProduceCategory>,
        onPeekFinished: (() async -> Void)? = nil
    ) {
        self.selectedTab = selectedTab
        self.searchQuery = searchQuery
        self.isSearching = isSearching
        self._selectedCategory = selectedCategory
        self.onPeekFinished = onPeekFinished
        self.periods = periods.enumerated().map {
            PeriodItem(id: $0.offset, title: $0.element.title)
        }
    }

    var body: some View {
        PeriodScrollContainer(
            periods: periods,
            initialIndex: Period.currentPeriod.index,
            onPeekFinished: onPeekFinished
        ) { item in
            let period = Array(Period.allCases)[item.id]

            ProduceListNavigationView(title: cellTitle(for: period)) {
                ProduceList(
                    produce: appCoordinator.produceStore.byPeriod(period, query: searchQuery),
                    selectedPeriodName: item.title,
                    parentTab: selectedTab,
                    selectedCategory: $selectedCategory
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
        .environmentObject(FeatureToggleHelper())
    }
}
#endif
