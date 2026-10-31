//
//  ProduceList.swift
//  Seasonal
//
//  Created by Clint Thomas on 27/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct ProduceList: View {

    let produce: [Produce]
    let parentTab: MainTabScreen.Tabs

    private let regularWidthMargin: CGFloat = .space5

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isSearching) private var isSearching
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var selectedCategory: ProduceCategory = .all
    var searchText = ""
    var periodTitle: String?

    var body: some View {
        let produce = filteredProduce
        Group {
            if produce.isEmpty {
                ProduceListEmptyState(
                    parentTab: parentTab,
                    category: selectedCategory,
                    periodTitle: periodTitle,
                    searchText: searchText
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(produce) { item in
                            ProduceListRow(produce: item, showMonths: parentTab != .seasons)
                                .padding(.top, .space1)
                                .transition(reduceMotion ? .opacity : .slide.combined(with: .opacity))
                        }
                    }
                    // The keyboard and the search field cover far more than the usual room at the bottom.
                    .padding(.bottom, isSearching ? .keyboardPadding : .space4)
                }
                .contentMargins(.horizontal, horizontalSizeClass == .regular ? regularWidthMargin : 0, for: .scrollContent)
                .accessibilityIdentifier("produceList")
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Colour.background)
    }

    var filteredProduce: [Produce] {
        produce
            .filter { selectedCategory == .all || $0.category == selectedCategory }
            .filter { searchText.isEmpty || $0.name?.localizedStandardContains(searchText) == true }
    }
}
