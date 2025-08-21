//
//  InfiniteTabToolbar.swift
//  Seasonal
//
//  Created by Clint Thomas on 17/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct InfiniteTabToolbar<Period: PeriodType>: ToolbarContent {

	private enum NavigationDirection {
		case previous, next
	}

	private let allCases = Array(Period.allCases)

	@Binding var selectedItem: Period
	@Binding var scrollPosition: Int
	private let middleOffset: Int

	init(selectedItem: Binding<Period>, scrollPosition: Binding<Int>, middleOffset: Int) {
		self._selectedItem = selectedItem
		self._scrollPosition = scrollPosition
		self.middleOffset = middleOffset
	}

	var body: some ToolbarContent {
		// <-
		ToolbarItem(placement: .navigationBarLeading) {
			Button {
				navigateToAdjacent(.previous)
			} label: {
				Image.arrowLeft
			}
			.buttonStyle(.plain)
			.foregroundColor(.primary)
		}
		.sharedBackgroundVisibility(.hidden)

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
						jumpToMonth(item)
					}
				}
			} label: {
				selectedItem.image
			}
			.buttonStyle(.plain)
			.foregroundColor(.primary)

			// ->
			Button {
				navigateToAdjacent(.next)
			} label: {
				Image.arrowRight
			}
			.buttonStyle(.plain)
			.foregroundColor(.primary)
		}
		.sharedBackgroundVisibility(.hidden)
	}

	private func navigateToAdjacent(_ direction: NavigationDirection) {
		let newPosition = switch direction {
		case .next: scrollPosition + 1
		case .previous: scrollPosition - 1
		}

			// Update selected item immediately for UI responsiveness
		let monthIndex = newPosition % allCases.count
		let adjustedIndex = monthIndex < 0 ? monthIndex + allCases.count : monthIndex
		selectedItem = allCases[adjustedIndex]

			// Animate to new position
		withAnimation(.easeInOut(duration: 0.5)) {
			scrollPosition = newPosition
		}
	}

	private func jumpToMonth(_ month: Period) {
		selectedItem = month
		withAnimation(.easeInOut(duration: 0.5)) {
			scrollPosition = month.index + middleOffset
		}
	}
}
