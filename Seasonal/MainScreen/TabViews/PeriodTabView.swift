	//
	//  PeriodTabView.swift
	//  Seasonal
	//
	//  Created by Clint Thomas on 19/8/2025.
	//  Copyright © 2025 Clint Thomas. All rights reserved.
	//

import SwiftUI

@available(iOS 26, *)
struct PeriodTabView<Period: PeriodType>: View {

	@EnvironmentObject var appCoordinator: AppCoordinator

	let selectedTab: MainTabScreen.Tabs
	private let allPeriods: [Period] = Period.allCases

	@Binding var selectedCategory: ProduceCategory

	@State var selectedPeriod: Period
	@State private var scrollPosition: Int?

	private var periodScrollView: some View {
		ScrollView(.horizontal) {
			LazyHStack(spacing: 0) {
				ForEach(allPeriods.indices, id: \.self) { index in
					let period = allPeriods[index]
//					periodCell(for: period, index: index)   // <- use index
//						.id(index)                           // <- ID type matches Int?
					if index % 2 == 0 {
						Color.blue
							.id(index)
					} else {
						Color.green
							.id(index)
					}
				}
			}
			.scrollTargetLayout()
		}
		.scrollTargetBehavior(.paging)
		.scrollPosition(id: $scrollPosition)               // <- simple binding
	}

	private func periodCell(for period: Period, index: Int) -> some View {
		ProduceList(
			selectedPeriod: period,
			parentTab: selectedTab,
			selectedCategory: $selectedCategory
		)
		.containerRelativeFrame(.horizontal)
		.padding(.top, -100)
		.onAppear { print("Cell appeared at index \(index)") }
		.onDisappear { print("Cell disappeared at index \(index)") }
	}

	var body: some View {
		NavigationView {
			periodScrollView
				.ignoresSafeArea(edges: .bottom)
				.onAppear {
					selectedPeriod = .currentPeriod        // only used to seed
					scrollPosition = selectedPeriod.index  // initial index
				}
				.toolbar {
					InfiniteTabToolbar<Period>(
						selectedPeriod: $selectedPeriod,
						scrollPosition: $scrollPosition
					)
				}
				.toolbarBackground(.hidden, for: .navigationBar)
		}
		.toolbarBackground(.hidden, for: .navigationBar)
	}

	

	private func periodCell(for period: Period, index: Int, scrollPosition: Int, preloadBefore: Int, preloadAfter: Int) -> some View {
		ProduceList(
			selectedPeriod: period,
			parentTab: selectedTab,
			selectedCategory: $selectedCategory
		)
		.containerRelativeFrame(.horizontal)
		.id(period)
		.padding(.top, -100)
		.onAppear {
			print("index loaded - \(index)")
			print("before - \(scrollPosition - preloadBefore)")
			print("after \(scrollPosition + preloadAfter)")
		}
	}

	private func updateSelectedPeriod(from newPosition: Int?) {
		guard let newPosition: Int else { return }
		selectedPeriod = Array(Period.allCases).element(atCyclicIndex: newPosition)
	}
}

@available(iOS 26, *)
#Preview {
	NavigationStack {
		PeriodTabView<Months>(selectedTab: .favourites, selectedCategory: .constant(.all), selectedPeriod: .april)
			.environmentObject(previewCoordinator)	
	}
}

