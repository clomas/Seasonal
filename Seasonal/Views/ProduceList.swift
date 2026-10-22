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

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isSearching) private var isSearching

    var selectedCategory: ProduceCategory = .all
    var searchText = ""

    var body: some View {
        let produce = filteredProduce
        Group {
            if produce.isEmpty {
                emptyState
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

    @ViewBuilder
    private var emptyState: some View {
        if searchText.isEmpty {
            ContentUnavailableView {
                Label {
                    Text(parentTab.emptyProduceListViewMessage)
                } icon: {
                    parentTab.emptyListIcon
                }
            }
        } else {
            ContentUnavailableView.search
        }
    }
}
