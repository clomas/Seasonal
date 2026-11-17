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

    @State private var pinnedSnapshot: Set<Int>?

    var selectedCategory: ProduceCategory = .all
    var searchText = ""
    var periodTitle: String?
    var pinsFavourites = false
    // The pager keeps neighbouring pages alive without `onDisappear`, so only the current page freezes its order.
    var isCurrentPage = true

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
                        ForEach(produce.listItems(pinning: pinnedIDs)) { item in
                            switch item {
                            case let .header(title):
                                ProduceListSectionHeader(title: title)
                            case let .produce(produce):
                                ProduceListRow(produce: produce, showMonths: parentTab != .seasons)
                                    .padding(.top, .space1)
                                    .transition(reduceMotion ? .opacity : .slide.combined(with: .opacity))
                            }
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
        .onChange(of: produce.favouriteIDs) { previous, _ in freezePinnedOrder(at: previous) }
        .onDisappear { clearPinnedSnapshot() }
        .onChange(of: searchText) { clearPinnedSnapshot() }
        .onChange(of: selectedCategory) { clearPinnedSnapshot() }
        .onChange(of: isCurrentPage) { clearPinnedSnapshot() }
    }

    var filteredProduce: [Produce] {
        produce
            .filter { selectedCategory == .all || $0.category == selectedCategory }
            .filter { searchText.isEmpty || $0.name?.localizedStandardContains(searchText) == true }
    }

    private var pinnedIDs: Set<Int> {
        Self.pinnedIDs(in: produce, snapshot: pinnedSnapshot, pinsFavourites: pinsFavourites, searchText: searchText)
    }

    static func pinnedIDs(in produce: [Produce], snapshot: Set<Int>?, pinsFavourites: Bool, searchText: String) -> Set<Int> {
        guard pinsFavourites, searchText.isEmpty else { return [] }
        return snapshot ?? produce.favouriteIDs
    }

    private func freezePinnedOrder(at ids: Set<Int>) {
        guard isCurrentPage, pinnedSnapshot == nil else { return }
        pinnedSnapshot = ids
    }

    // Writing state mid-scroll cancels the pager's animated scroll, so only write when there's a snapshot to clear.
    private func clearPinnedSnapshot() {
        guard pinnedSnapshot != nil else { return }
        pinnedSnapshot = nil
    }
}
