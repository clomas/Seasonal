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
	private let initialProduce: [Produce]?

	@EnvironmentObject var appCoordinator: AppCoordinator

	@State var selectedPeriod: Period
	@State var parentTab: MainTabScreen.Tabs
	@State private var produce: [Produce] = []

	@Binding var selectedCategory: ProduceCategory

	var searchText: String = ""

	var filteredProduce: [Produce] {
		guard !searchText.isEmpty else { return produce }
		return produce.filter {
			$0.name?.localizedCaseInsensitiveContains(searchText) == true
		}
	}

	init(
		selectedPeriod: Period,
		parentTab: MainTabScreen.Tabs,
		selectedCategory: Binding<ProduceCategory>,
		produce: [Produce]? = nil,
		searchText: String = ""
	) {
		self.selectedPeriod = selectedPeriod
		self.parentTab = parentTab
		self._selectedCategory = selectedCategory
		self.initialProduce = produce
		self.searchText = searchText
	}

	var body: some View {
		ZStack {
			Colour.background.ignoresSafeArea()

			if filteredProduce.isEmpty {
				emptyProduceListView
					.padding(.bottom, .largePadding)
			} else {
				List(filteredProduce, id: \.id) { item in
					ProduceListRow(produce: .constant(item))
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
				.safeAreaInset(edge: .top) {
					Color.clear.frame(height: 100)
				}
			}
		}
		.onAppear {
			if let initialProduce {
				produce = initialProduce
			} else {
				produce = appCoordinator.produceStore.byPeriod(selectedPeriod)
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

    private var navigationTitleText: String {
        switch parentTab {
        case .period(_):
            selectedPeriod.name
        default:
            parentTab.title
        }
    }
}
