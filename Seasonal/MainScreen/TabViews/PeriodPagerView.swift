//
//  PeriodTabView.swift
//  Seasonal
//
//  Created by Clint Thomas on 19/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct PeriodPagerView<Period: PeriodType>: View {

    @EnvironmentObject var produceStore: ProduceStore
    @Environment(MainScreenState.self) private var state

    @Binding var jumpToIndex: Int?
    @Binding var currentIndex: Int

    let searchText: String
    let onPeekFinished: (() async -> Void)?

    private let periods = Period.allCases.enumerated().map { PeriodItem(id: $0.offset, title: $0.element.title) }

    init(
        jumpToIndex: Binding<Int?> = .constant(nil),
        currentIndex: Binding<Int> = .constant(0),
        searchText: String = "",
        onPeekFinished: (() async -> Void)? = nil
    ) {
        self._jumpToIndex = jumpToIndex
        self._currentIndex = currentIndex
        self.searchText = searchText
        self.onPeekFinished = onPeekFinished
    }

    var body: some View {
        PeriodScrollContainer(
            periods: periods,
            initialIndex: currentIndex,
            jumpToIndex: $jumpToIndex,
            currentIndex: $currentIndex,
            onPeekFinished: onPeekFinished
        ) { item in
            ProduceList(
                produce: produceStore.byPeriod(Period.allCases[item.id]),
                parentTab: state.browsingTab,
                selectedCategory: state.selectedCategory,
                searchText: searchText
            )
        }
    }
}

#if DEBUG
@available(iOS 26, *)
#Preview {
    NavigationStack {
        PeriodPagerView<Months>()
            .environmentObject(previewCoordinator)
            .environmentObject(previewCoordinator.produceStore)
            .environment(MainScreenState())
    }
}
#endif
