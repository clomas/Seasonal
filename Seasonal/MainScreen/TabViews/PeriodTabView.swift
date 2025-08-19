//
//  PeriodTabView.swift
//  Seasonal
//
//  Created by Clint Thomas on 19/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

struct PeriodTabView<Period: PeriodType>: View {

	let produce: [ProduceModel]

	private let middleOffset = Period.allCases.count

	@State var selectedPeriod: Period
	@State var selectedCategory: ViewDisplayed.ProduceCategory = .all
	@State var searchQuery: String = ""

	@State private var scrollPosition: Int = 0

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
						selectedItem: $selectedPeriod,
						scrollPosition: $scrollPosition,
						middleOffset: middleOffset
					)
				}
				.toolbarBackground(.hidden, for: .navigationBar)
		}
	}

	private func periodCell(for period: Period, index: Int) -> some View {
		ProduceList(
			// TODO: category
			produce: produce.filtered(by: period, category: .all, search: ""),
			period: period, selectedTab: .months
		)
		.containerRelativeFrame(.horizontal)
		.id(index)
		.padding(.top, -100)
	}

	private func periodMenu() -> some View {
		Menu {
			ForEach(Array(Period.allCases), id: \.self) { period in
				Button("\(period.name)") {
					selectedPeriod = period
				}
			}
		} label: {
			Label(selectedPeriod.name, systemImage: .calendarImage)
				.glassEffect(.regular)
		}
	}

	private func updateScrollPosition(to newPosition: Int?) {
		guard let newPosition: Int else {
			return
		}
		scrollPosition = newPosition
		updateCurrentPeriod(from: newPosition)
	}

	private func updateCurrentPeriod(from scrollPosition: Int) {
		let periodIndex = scrollPosition % Period.allCases.count
		selectedPeriod = Array(Period.allCases)[periodIndex]
	}

	private func setHorizontalScrollPosition(for updatedPeriod: Period) {
		withAnimation(.easeInOut(duration: .lazyHStackScrollDuration)) {
			updateScrollPosition(to: updatedPeriod.index + middleOffset)
		}
	}
}

#Preview {
	lazy var coord: AppCoordinator = {
		let coord = AppCoordinator(window: .create())
		coord.state = .locationNotFound
		coord.produceData = [
			ProduceModel(
				id: 0,
				name: "Apples",
				category: .fruit,
				imageName: "Apples",
				description: "",
				months: [.march],
				seasons: [.autumn, .spring],
				liked: true
			),
			ProduceModel(
				id: 1,
				name: "Bananas",
				category: .fruit,
				imageName: "Bananas",
				description: "",
				months: [.april, .august, .december, .january, .june, .september, .february],
				seasons: [.autumn, .spring],
				liked: true
			),
			ProduceModel(
				id: 2,
				name: "Carrots",
				category: .vegetables,
				imageName: "Carrots",
				description: "",
				months: [.april, .august, .december, .january, .june, .september],
				seasons: [.autumn, .spring],
				liked: true
			),
			ProduceModel(
				id: 3,
				name: "Broccoli",
				category: .vegetables,
				imageName: "Broccoli",
				description: "",
				months: [.april, .august, .december, .january, .june, .september, .may],
				seasons: [.autumn, .spring],
				liked: true
			),
			ProduceModel(
				id: 4,
				name: "Spinach",
				category: .vegetables,
				imageName: "Spinach",
				description: "",
				months: [.april, .august, .april, .january, .june, .september],
				seasons: [.autumn, .spring],
				liked: true
			),
			ProduceModel(
				id: 5,
				name: "Tomatoes",
				category: .vegetables,
				imageName: "Tomatoes",
				description: "",
				months: [.april, .august, .december, .january, .september, .february],
				seasons: [.autumn, .spring],
				liked: true
			),
			ProduceModel(
				id: 0,
				name: "Apples",
				category: .fruit,
				imageName: "Apples",
				description: "",
				months: [.june, .september, .july, .april, .february, .may, .march],
				seasons: [.autumn, .spring],
				liked: true
			),
			ProduceModel(
				id: 1,
				name: "Bananas",
				category: .fruit,
				imageName: "Bananas",
				description: "",
				months: [.april, .august, .december, .january, .june, .september, .february],
				seasons: [.autumn, .spring],
				liked: true
			),
			ProduceModel(
				id: 2,
				name: "Carrots",
				category: .vegetables,
				imageName: "Carrots",
				description: "",
				months: [.april, .august, .december, .january, .june, .september],
				seasons: [.autumn, .spring],
				liked: true
			),
			ProduceModel(
				id: 3,
				name: "Broccoli",
				category: .vegetables,
				imageName: "Broccoli",
				description: "",
				months: [.april, .august, .december, .january, .june, .september, .may],
				seasons: [.autumn, .spring],
				liked: true
			),
			ProduceModel(
				id: 4,
				name: "Spinach",
				category: .vegetables,
				imageName: "Spinach",
				description: "",
				months: [.april, .august, .april, .january, .june, .september],
				seasons: [.autumn, .spring],
				liked: true
			),
			ProduceModel(
				id: 5,
				name: "Tomatoes",
				category: .vegetables,
				imageName: "Tomatoes",
				description: "",
				months: [.april, .august, .december, .january, .september, .february],
				seasons: [.autumn, .spring],
				liked: true
			),
		]
		return coord
	}()

	NavigationStack {
		PeriodTabView<Months>(produce: coord.produceData ?? [], selectedPeriod: .april)
			.environmentObject(coord)
	}
}
