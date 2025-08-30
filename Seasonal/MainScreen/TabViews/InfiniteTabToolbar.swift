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
	@Binding var scrollPosition: Int?

	private var displayedPeriod: Period { // TODO: not sure i need this, binding should work
		let idx = scrollPosition ?? selectedPeriod.index
		return allCases.element(atCyclicIndex: idx)
	}

	var body: some ToolbarContent {
		// Title
		ToolbarItem(placement: .topBarLeading) {
			Text(displayedPeriod.name)
				.font(.title)
				.fixedSize()
				.animation(.smooth, value: displayedPeriod.name)
		}
		.sharedBackgroundVisibility(.hidden)

			// (🗓️ ->)
		ToolbarItemGroup(placement: .navigationBarTrailing) {
				// <-
			Button {
				incrementScrollPosition(.previous)
			} label: {
				Image.arrowLeft
			}
			.foregroundStyle(.black) // TODO: Update to my colours for dark mode

				// 🗓️ picker
			Menu {
				ForEach(Period.allCases, id: \.self) { period in
					Button(period.name) {
						jumpToPeriod(period) // TODO: This doesn't work, should I use this in the period views?
					}
				}
			} label: {
				displayedPeriod.image
			}
			.foregroundStyle(.primary)

				// ->
			Button {
				incrementScrollPosition(.next)
			} label: {
				Image.arrowRight
			}
			.foregroundStyle(.primary)
		}
	}

	private func incrementScrollPosition(_ direction: NavigationDirection) {
		let current = scrollPosition ?? selectedPeriod.index
		let newPosition = (direction == .next) ? current + 1 : current - 1

		withAnimation(.easeInOut(duration: 0.5)) {
			scrollPosition = newPosition
			print("infinitetabtoolbar: \(newPosition)")
		}
	}

	private func jumpToPeriod(_ period: Period) {
		withAnimation(.easeInOut(duration: 0.5)) {
			scrollPosition = period.index
			print("infinite jump: \(String(describing: scrollPosition))")
		}
	}
}
// TODO: Prevent reaching the end and changing the titles still

