//
//  ProduceList.swift
//  Seasonal
//
//  Created by Clint Thomas on 27/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct ProduceList<Period: PeriodType>: View {

	let selectedPeriod: Period
	let parentTab: MainTabScreen.Tabs

	@Binding var selectedCategory: ProduceCategory

	@State var produce: [Produce]
	@State private var query: String = ""

	@FocusState private var searchIsFocused: Bool

	var onToggleLike: ToggleLikeCallback

	private var filteredProduce: [Produce] {
		produce.filtered(by: selectedPeriod, category: selectedCategory, search: query)
	}

	var body: some View {
		ZStack {
			Colour.background.ignoresSafeArea()

			if produce.isEmpty {
				emptyProduceListView
					.padding(.bottom, .largePadding)
			} else {
				List($produce, id: \.id) { $item in
					ProduceListRow(produce: $item, onToggleLike: onToggleLike)
						.listRowSeparator(.hidden)
						.listRowInsets(.topListRowInset)
						.listRowBackground(Color.clear)

				}
//				.searchable(text: $query, placement: .sidebar, prompt: "Search produce")
//				.focused($searchIsFocused)
//				.onAppear {
//					if case .search = parentTab {
//						searchIsFocused = true
//					}
//				}
				.listStyle(.plain)
				.scrollContentBackground(.hidden)
				.scrollIndicators(.hidden)
				.safeAreaInset(edge: .bottom) {
					Color.clear.frame(height: .largePadding)
				}
			}
		}
	}

	private var emptyProduceListView: some View {
		VStack(spacing: 6) {
			Image.settings
				.resizable()
				.frame(width: 50, height: 50)
				.padding(20)
			Text(parentTab.emptyProduceListViewMessage ?? String.nothingToSeeHereMessage(tryAnother: selectedPeriod.nameLowercased))
		}
	}
}
