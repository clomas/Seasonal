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

	@Binding var selectedPeriod: Period
	@Binding var scrollPosition: Int
	private let middleOffset: Int

	init(selectedPeriod: Binding<Period>, scrollPosition: Binding<Int>, middleOffset: Int) {
		self._selectedPeriod = selectedPeriod
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
			.foregroundStyle(.black) // TODO: Update to my colours for dark mode
		}
        // Title
        ToolbarItem(placement: .topBarLeading) {
            Text(selectedPeriod.name)
                .font(.title)
                .fixedSize()
        }
        .sharedBackgroundVisibility(.hidden)

		// (🗓️ ->)
		ToolbarItemGroup(placement: .navigationBarTrailing) {
			// 🗓️ picker
			Menu {
				ForEach(Period.allCases, id: \.self) { period in
					Button(period.name) {
						jumpToPeriod(period)
					}
				}
			} label: {
				selectedPeriod.image
			}
			.foregroundStyle(.black)

			// ->
			Button {
				navigateToAdjacent(.next)
			} label: {
				Image.arrowRight
			}
			.foregroundStyle(.black)
		}
	}

	private func navigateToAdjacent(_ direction: NavigationDirection) {
		let newPosition = switch direction {
		case .next: scrollPosition + 1
		case .previous: scrollPosition - 1
		}

			// Update selected item immediately for UI responsiveness
		let periodIndex = newPosition % allCases.count
		let adjustedIndex = periodIndex < 0 ? periodIndex + allCases.count : periodIndex
		selectedPeriod = allCases[adjustedIndex]

			// Animate to new position
		withAnimation(.easeInOut(duration: 0.5)) {
			scrollPosition = newPosition
		}
	}

	private func jumpToPeriod(_ period: Period) {
		selectedPeriod = period
		withAnimation(.easeInOut(duration: 0.5)) {
			scrollPosition = period.index + middleOffset
		}
	}
}
