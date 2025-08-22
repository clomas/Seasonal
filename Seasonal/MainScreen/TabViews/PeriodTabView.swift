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

	let produce: [Produce]
	let selectedTab: MainTabScreen.Tabs

	private let middleOffset = Period.allCases.count

	@Binding var selectedCategory: ProduceCategory

	@State var selectedPeriod: Period
	@State private var scrollPosition: Int = 0

	var onToggleLike: ToggleLikeCallback

	private var infinitePeriods: [Period] {
		Array(repeating: Period.allCases, count: 3).flatMap { $0 }
	}

	private var periodScrollView: some View {
		GeometryReader { geo in
			ScrollView(.horizontal) {
				LazyHStack(spacing: 0) {
					ForEach(Array(infinitePeriods.enumerated()), id: \.offset) { index, period in
						periodCell(for: period, index: index)
					}
				}
				.scrollTargetLayout()
			}
			.scrollTargetBehavior(.paging)
			.scrollPosition(id: .init(
				get: { scrollPosition },
				set: { updateScrollPosition(to: $0) }
			))
		}
	}

	var body: some View {
		NavigationView {
			periodScrollView
				.ignoresSafeArea(edges: .bottom)
				.onAppear {
					selectedPeriod = .currentPeriod
					updateScrollPosition(to: selectedPeriod.index + middleOffset)
				}
				.toolbar {
					InfiniteTabToolbar<Period>(
						selectedPeriod: $selectedPeriod,
						scrollPosition: $scrollPosition,
						middleOffset: middleOffset
					)
				}
				.toolbarBackground(.hidden, for: .navigationBar)
		}
		.toolbarBackground(.hidden, for: .navigationBar)
	}

	private func periodCell(for period: Period, index: Int) -> some View {
		ProduceList(
			selectedPeriod: period,
			parentTab: selectedTab,
			selectedCategory: $selectedCategory,
			produce: produce.filtered(by: period, category: selectedCategory, search: ""),
			onToggleLike: onToggleLike
		)
		.containerRelativeFrame(.horizontal)
		.id(index)
		.padding(.top, -100)
	}

	private func updateScrollPosition(to newPosition: Int?) {
		guard let newPosition: Int else {
			return
		}
		scrollPosition = newPosition
		updateCurrentPeriod(from: newPosition)
	}

	private func updateCurrentPeriod(from scrollPosition: Int) {
		let periodIndex: Int = scrollPosition % Period.allCases.count
		print("before: \(selectedPeriod) index: \(periodIndex)")
		selectedPeriod = Array(Period.allCases)[periodIndex]
		print("after: \(selectedPeriod)")
	}
}

@available(iOS 26, *)
#Preview {
	NavigationStack {
		PeriodTabView<Months>(produce: previewCoordinator.produceData ?? [], selectedTab: .favourites, selectedCategory: .constant(.all), selectedPeriod: .april, onToggleLike: { _ in })
			.environmentObject(previewCoordinator)
	}
}
