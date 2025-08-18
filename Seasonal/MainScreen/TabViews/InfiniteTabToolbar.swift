//
//  InfiniteTabToolbar.swift
//  Seasonal
//
//  Created by Clint Thomas on 17/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

struct InfiniteTabToolbar<Period: PeriodType>: ToolbarContent {

	private let allCases = Array(Period.allCases)

	@Binding var selectedItem: Period
	let onNavigate: (NavigationDirection) -> Void

	enum NavigationDirection {
		case previous, next
	}

	init(selectedItem: Binding<Period>, onNavigate: @escaping (NavigationDirection) -> Void) {
		self._selectedItem = selectedItem
		self.onNavigate = onNavigate
	}

	var body: some ToolbarContent {
			// <-
		ToolbarItem(placement: .navigationBarLeading) {
			Button {
				onNavigate(.previous)
			} label: {
				Image.arrowLeft
			}
			.buttonStyle(.plain)
		}

			// Month name
		ToolbarItem(placement: .topBarLeading) {
			Text(selectedItem.name)
				.font(.title)
				.fixedSize()
		}
		.sharedBackgroundVisibility(.hidden)

			// (🗓️ ->)
		ToolbarItemGroup(placement: .navigationBarTrailing) {
				// 🗓️ picker
			Menu {
				ForEach(Period.allCases, id: \.self) { item in
					Button(item.name) {
						selectedItem = item
					}
				}
			} label: {
				selectedItem.image
			}
			.buttonStyle(.plain)

				// ->
			Button {
				onNavigate(.next)
			} label: {
				Image.arrowRight
			}
			.buttonStyle(.plain)
		}
	}
}

	// Add this method to your MonthsTabView:
	// private func navigateToAdjacentMonth(_ direction: InfiniteTabToolbar<Month>.NavigationDirection) {
	//     let newPosition = switch direction {
	//     case .next: scrollPosition + 1
	//     case .previous: scrollPosition - 1
	//     }
	//
	//     withAnimation(.easeInOut(duration: 0.5)) {
	//         scrollPosition = newPosition
	//     }
	// }
	//
	// And use it in your toolbar:
	// .toolbar {
	//     InfiniteTabToolbar<Month>(selectedItem: $selectedMonth) { direction in
	//         navigateToAdjacentMonth(direction)
	//     }
	// }

	// Update your MonthsTabView toolbar call to:
	// .toolbar {
	//     InfiniteTabToolbar<Month>(
	//         selectedItem: $selectedMonth,
	//         scrollPosition: $scrollPosition
	//     )
	// }

	// And remove the onChange that calls setHorizontalScrollPosition -
	// let the scroll position drive the selectedMonth instead

	// Update your MonthsTabView to handle the navigation:
	// .toolbar {
	//     InfiniteTabToolbar<Month>(selectedItem: $selectedMonth) { direction in
	//         let currentIndex = selectedMonth.index
	//         let newIndex = switch direction {
	//         case .previous: (currentIndex - 1 + Month.allCases.count) % Month.allCases.count
	//         case .next: (currentIndex + 1) % Month.allCases.count
	//         }
	//         let newMonth = Month.allCases[newIndex]
	//         selectedMonth = newMonth
	//         // This will trigger your onChange which calls setHorizontalScrollPosition
	//     }
	// }

	// Update your MonthsTabView toolbar call to:
	// .toolbar {
	//     InfiniteTabToolbar<Month>(
	//         selectedItem: $selectedMonth,
	//         scrollPosition: $scrollPosition,
	//         middleOffset: middleOffset
	//     )
	// }
	// Update your MonthsTabView toolbar call to:
	// .toolbar {
	//     InfiniteTabToolbar<Month>(
	//         selectedItem: $selectedMonth,
	//         scrollPosition: $scrollPosition,
	//         middleOffset: middleOffset
	//     )
	// }
