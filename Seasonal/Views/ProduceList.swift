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
    var selectedCategory: ProduceCategory = .all
    var searchText = ""

    var body: some View {
        ZStack {
            Colour.background.ignoresSafeArea()

            if filteredProduce.isEmpty {
                EmptyStateView(icon: parentTab.emptyListIcon, message: emptyMessage)
                    .padding(.bottom, .largePadding)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredProduce, id: \.id) { item in
                            ProduceListRow(produce: item, showMonths: !parentTab.isSeasons)
                                .padding(.topListRowInset)
                                .transition(.slide.combined(with: .opacity))
                        }
                    }
                    .padding(.bottom, .largePadding)
                }
                .accessibilityIdentifier("produceList")
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.immediately)
            }
        }
    }

    /// Kept a pure function of the inputs so it can be unit tested without rendering.
    var filteredProduce: [Produce] {
        produce
            .filter { selectedCategory == .all || $0.category == selectedCategory }
            .filter { searchText.isEmpty || $0.name?.localizedCaseInsensitiveContains(searchText) == true }
    }

    private var emptyMessage: String {
        searchText.isEmpty ? parentTab.emptyProduceListViewMessage : Strings.Search.noResults
    }
}
