//
//  SearchTabView.swift
//  Seasonal
//
//  Created by Clint Thomas on 21/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct SearchTabView<Period: PeriodType>: View {

	let produce: [Produce]
	let selectedTab: MainTabScreen.Tabs

	let selectedPeriod: Period

	@Binding var selectedCategory: ProduceCategory

	var body: some View {
		NavigationStack {
			if selectedTab == .favourites {
				ProduceList(
					selectedPeriod: selectedPeriod,
					parentTab: selectedTab,
					selectedCategory: $selectedCategory,
					produce: produce
				)
				.environmentObject(ProduceStore())
			} else {
				PeriodTabView(
					selectedTab: selectedTab,
					selectedCategory: $selectedCategory,
					selectedPeriod: selectedPeriod
				)
			}
		}
	}
}

@available(iOS 26, *)
#Preview {
	SearchTabView(
		produce: previewCoordinator.produceStore.allProduce,
		selectedTab: .period(AnyPeriod(Months.currentPeriod)),
		selectedPeriod: Months.currentPeriod,
		selectedCategory: .constant(.all)
	)
}
