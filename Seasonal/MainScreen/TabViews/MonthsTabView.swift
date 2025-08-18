//
//  MonthsTabView.swift
//  Seasonal
//
//  Created by Clint Thomas on 3/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

struct MonthsTabView: View {

	@State var selectedMonth: Month
	@State var selectedCategory: ViewDisplayed.ProduceCategory = .all
	@State var searchQuery: String = ""

	@State private var scrollPosition: Int = 0

	let produce: [ProduceModel]

	private let middleOffset = Month.allCases.count

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
				.onAppear {
					selectedMonth = .thisMonth
					// Set scroll position to match the selected month
					scrollPosition = selectedMonth.index + middleOffset
				}
				.onChange(of: selectedMonth) { _, updatedMonth in
						//					setHorizontalScrollPosition(for: updatedMonth)
				}
				.toolbar {
					InfiniteTabToolbar<Month>(
						selectedItem: $selectedMonth,
						scrollPosition: $scrollPosition,
						middleOffset: middleOffset
					)
				}
				.toolbarBackground(.visible, for: .navigationBar)
				.toolbarBackground(Color.clear, for: .navigationBar)
		}
	}

	private func monthCell(for month: Month, index: Int) -> some View {
		ProduceList(produce: produce.filtered(by: .months(month, category: selectedCategory, search: searchQuery)))
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
	}

	private func updateCurrentMonth(from scrollPosition: Int) {
		let monthIndex = scrollPosition % Month.allCases.count
		selectedMonth = Month.allCases[monthIndex]
	}

	private func monthMenu() -> some View {
		Menu {
			ForEach(Month.allCases, id: \.self) { month in
				Button(month.name) {
					selectedMonth = month
						// Remove the TODO - the onChange will handle the scroll position
				}
			}
		} label: {
			Label("Month", systemImage: "calendar")
				.glassEffect(.regular)
		}
	}

	private func setHorizontalScrollPosition(for updatedMonth: Month) {
		withAnimation(.easeInOut(duration: 0.5)) {
			scrollPosition = updatedMonth.index + middleOffset
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
		MonthsTabView(selectedMonth: .april, produce: coord.produceData ?? [])
			.environmentObject(coord)
	}
}
