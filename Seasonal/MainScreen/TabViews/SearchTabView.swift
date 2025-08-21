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

	var onToggleLike: ToggleLikeCallback

	var body: some View {
		NavigationStack {
			if selectedTab == .favourites {
				ProduceList(
					selectedPeriod: selectedPeriod,
					parentTab: selectedTab,
					selectedCategory: $selectedCategory,
					produce: produce, onToggleLike: onToggleLike
				)
			} else {
				PeriodTabView(
					produce: produce,
					selectedTab: selectedTab,
					selectedCategory: $selectedCategory,
					selectedPeriod: selectedPeriod,
					onToggleLike: onToggleLike
				)
			}
		}
	}
}

@available(iOS 26, *)
#Preview {
	SearchTabView(
		produce: previewCoordinator.produceData ?? [],
		selectedTab: .period(AnyPeriod(Months.currentPeriod)),
		selectedPeriod: Months.currentPeriod,
		selectedCategory: .constant(.all),
		onToggleLike: { _ in }
	)
}
