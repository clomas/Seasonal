//
//  SearchView.swift
//  Seasonal
//
//  Created by Clint Thomas on 21/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct SearchView<Period: PeriodType>: View {

	let produce: [Produce]
	let selectedTab: MainTabScreen.Tabs

	@Binding var selectedPeriod: Period
	@Binding var selectedCategory: ProduceCategory

	@State private var query: String = ""
	@FocusState private var searchIsFocused: Bool

	var filteredProduce: [Produce] {
		produce.filtered(by: selectedPeriod, category: selectedCategory, search: query)
	}

	var body: some View {
		NavigationStack {
			if selectedTab == .favourites {
				ProduceList(produce: filteredProduce, period: Months.currentPeriod, parentTab: selectedTab)
					.searchable(text: $query, prompt: "Search produce")
					.focused($searchIsFocused)
					.onAppear {
						searchIsFocused = true
					}
			} else {
				PeriodTabView(
					produce: produce,
					selectedTab: selectedTab,
					selectedCategory: $selectedCategory,
					selectedPeriod: selectedPeriod,
					searchQuery: query
				)
			}
		}
	}
}

@available(iOS 26, *)
#Preview {
	SearchView(produce: previewCoordinator.produceData ?? [], selectedTab: .months, selectedPeriod: .constant(Months.currentPeriod), selectedCategory: .constant(.all))
}
