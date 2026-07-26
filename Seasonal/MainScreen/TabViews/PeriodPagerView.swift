//
//  PeriodTabView.swift
//  Seasonal
//
//  Created by Clint Thomas on 19/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

/// `Sendable` because a period is looked up off the main actor (in the pager's cell builder)
/// and then handed to the main-actor-isolated `ProduceStore` — both conformers are plain
/// `Int`-backed enums, so it costs nothing.
protocol PeriodType: CaseIterable, Hashable, Sendable where AllCases == [Self] {
    static var currentPeriod: Self { get }

    var title: String { get }
    var index: Int { get }
    var cacheKey: ProduceCacheKey { get }

    func contains(_ produce: Produce) -> Bool
}

@available(iOS 26, *)
struct PeriodPagerView<Period: PeriodType>: View {

    @EnvironmentObject var produceStore: ProduceStore
    /// The search query, category filter and selected tab all come from here rather than as
    /// arguments — this view only forwards them, it never decides them.
    @Environment(MainScreenState.self) private var state

    private let periods: [PeriodItem]

    /// Set by the (lifted) calendar button to scroll this pager to a period; reset to nil once handled.
    @Binding var jumpToIndex: Int?
    /// Reports the period index currently centred in the pager, so the jump menu can tick it.
    @Binding var currentIndex: Int

    var onPeekFinished: (() async -> Void)? = nil

    init(
        periods: [Period],
        jumpToIndex: Binding<Int?> = .constant(nil),
        currentIndex: Binding<Int> = .constant(0),
        onPeekFinished: (() async -> Void)? = nil
    ) {
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

            ProduceListNavigationView(title: state.listTitle(for: item.title)) {
                ProduceList(
                    produce: produceStore.byPeriod(period, query: state.searchQuery),
                    parentTab: state.selectedTab,
                    selectedCategory: state.selectedCategory
                )
            }
        }
    }
}

#if DEBUG
@available(iOS 26, *)
#Preview {
    NavigationStack {
        PeriodPagerView<Months>(periods: Array(Months.allCases))
            .environmentObject(previewCoordinator)
            .environmentObject(previewCoordinator.produceStore)
            .environmentObject(FeatureToggleHelper())
            .environment(MainScreenState())
    }
}
#endif
