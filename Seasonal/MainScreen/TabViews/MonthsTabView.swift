//
//  MonthsTabView.swift
//  Seasonal
//
//  Created by Clint Thomas on 3/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

struct MonthsTabView: View {

	let produce: [ProduceModel]
	@Binding var selectedTab: Tabs

	private let middleOffset = Month.allCases.count
	@State private var scrollPosition: Int = Month.allCases.count

	// TODO:  Create 3 copies of months for infinite scrolling
	private var infiniteMonths: [Month] {
		Array(repeating: Month.allCases, count: 3).flatMap { $0 }
	}

	private var monthsScrollView: some View {
		GeometryReader { geo in
			ScrollView(.horizontal) {
				LazyHStack(spacing: 0) {
					ForEach(Array(infiniteMonths.enumerated()), id: \.offset) { index, month in
						monthCell(for: month, index: index)
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
			monthsScrollView
				.ignoresSafeArea(edges: .bottom)
				.onChange(of: selectedTab) { _, newValue in
					if case let .months(month, _, _) = newValue {
						let newIndex = month.index + middleOffset
						withAnimation(.easeInOut(duration: 0.3)) {
							scrollPosition = newIndex
						}
					}
				}
				.onAppear {
					onAppear()
				}
				.toolbar {
					MonthsTabToolbar(
						scrollPosition: $scrollPosition,
						middleOffset: middleOffset,
						selectedTab: $selectedTab
					)
				}
				.toolbarBackground(.visible, for: .navigationBar)
				.toolbarBackground(Color.clear, for: .navigationBar)
		}
	}

	// TODO: extract this into a helper
	private func onAppear() {
		selectedTab = .months(Month.thisMonth, category: .all, search: "")
	}

	private func monthCell(for month: Month, index: Int) -> some View {
		ProduceList(produce: produce.filtered(by: $selectedTab.wrappedValue))
			.containerRelativeFrame(.horizontal)
			.id(index)
			.padding(.top, -100)
	}

	private func updateScrollPosition(to newPosition: Int?) {
		guard let newPosition: Int else {
			return
		}
		scrollPosition = newPosition
		updateCurrentMonth(from: newPosition)

		// Add a small delay to avoid conflicts with scroll repositioning
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			handleInfiniteScroll(position: newPosition)
		}
	}

	private func updateCurrentMonth(from scrollPosition: Int) {
		let monthIndex = scrollPosition % Month.allCases.count
		let newMonth = Month.allCases[monthIndex]

		if case let .months(_, currentCategory, search) = selectedTab {
			selectedTab = .months(newMonth, category: currentCategory, search: search)
		}
	}

	private func handleInfiniteScroll(position: Int) {
		let totalMonths = Month.allCases.count

		// If we're at the first set (positions 0-11), jump to middle set
		if position < totalMonths {
			scrollPosition = position + totalMonths
		}
		// If we're at the last set (positions 24-35), jump to middle set
		else if position >= totalMonths * 2 {
			scrollPosition = position - totalMonths
		}
	}

	private func monthMenu() -> some View {
		Menu {
			ForEach(Month.allCases, id: \.self) { month in
				Button(month.name) {
					selectedTab = .months(month, category: .all, search: "") // TODO: track category here and search
					let newIndex = month.index + middleOffset
					withAnimation(.easeInOut(duration: 0.3)) {
						scrollPosition = newIndex
					}
				}
			}
		} label: {
			Label("Month", systemImage: "calendar")
				.glassEffect(.regular)
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
		MonthsTabView(produce: coord.produceData ?? [], selectedTab: .constant(Tabs.months(.august, category: .all, search: "")))
			.environmentObject(coord)
	}
}
