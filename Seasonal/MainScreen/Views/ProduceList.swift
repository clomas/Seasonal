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
	@EnvironmentObject var appCoordinator: AppCoordinator

	@State var selectedPeriod: Period
	@State var parentTab: MainTabScreen.Tabs
	@Binding var selectedCategory: ProduceCategory

	@State private var produce: [Produce] = []
	private let initialProduce: [Produce]?

	init(
		selectedPeriod: Period,
		parentTab: MainTabScreen.Tabs,
		selectedCategory: Binding<ProduceCategory>,
		produce: [Produce]? = nil
	) {
		self.selectedPeriod = selectedPeriod
		self.parentTab = parentTab
		self._selectedCategory = selectedCategory
		self.initialProduce = produce
	}

	var body: some View {
		ZStack {
			Colour.background.ignoresSafeArea()

			if produce.isEmpty {
				emptyProduceListView
					.padding(.bottom, .largePadding)
			} else {
				List($produce, id: \.id) { $item in
					ProduceListRow<Period>(
						selectedPeriod: selectedPeriod,
						produce: $item,
						onToggleLike: { tappedProduce in
							appCoordinator.updateLikedProduce(id: tappedProduce.id, liked: tappedProduce.liked)
						}
					)
					.listRowSeparator(.hidden)
					.listRowInsets(.topListRowInset)
					.listRowBackground(Color.clear)
				}
				.listStyle(.plain)
				.scrollContentBackground(.hidden)
				.scrollIndicators(.hidden)
				.safeAreaInset(edge: .bottom) {
					Color.clear.frame(height: .largePadding)
				}
			}
		}
		.onAppear {
			if let initialProduce {
				produce = initialProduce
			} else {
				produce = appCoordinator.produceByPeriod(period: selectedPeriod)
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
