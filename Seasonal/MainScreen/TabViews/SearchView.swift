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

	let selectedPeriod: Period

	@Binding var selectedCategory: ProduceCategory

	var onToggleLike: ToggleLikeCallback

	@State private var query: String = ""

	@FocusState private var searchIsFocused: Bool

	var filteredProduce: [Produce] {
		produce.filtered(by: selectedPeriod, category: selectedCategory, search: query)
	}

	var body: some View {
		TransparentBackgroundNavigationStack {
			Group {
				if selectedTab == .favourites {
					withSearchModifiers(
						ProduceList(period: selectedPeriod, parentTab: selectedTab, produce: produce, onToggleLike: onToggleLike)
					)
				} else {
					withSearchModifiers(
						PeriodTabView(
							produce: produce,
							selectedTab: selectedTab,
							selectedCategory: $selectedCategory,
							selectedPeriod: selectedPeriod,
							searchQuery: query,
							onToggleLike: onToggleLike
						)
					)
				}
			}
		}
	}

	private func withSearchModifiers<V: View>(_ view: V) -> some View {
		view
			.searchable(text: $query, prompt: "Search produce")
			.focused($searchIsFocused)
			.onAppear {
				searchIsFocused = true
			}
	}
}

@available(iOS 26, *)
#Preview {
	SearchView(
		produce: previewCoordinator.produceData ?? [],
		selectedTab: .period(AnyPeriod(Months.currentPeriod)),
		selectedPeriod: Months.currentPeriod,
		selectedCategory: .constant(.all),
		onToggleLike: { _ in }
	)
}
