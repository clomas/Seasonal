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
	@EnvironmentObject var featureToggleHelper: FeatureToggleHelper

	let selectedTab: MainTabScreen.Tabs
	private let allPeriods: [Period] = Period.allCases

	@Binding var selectedCategory: ProduceCategory

	@State var selectedPeriod: Period
	@State private var peekOffset: CGFloat = 0
	@State private var scrollPosition: ScrollPosition = .init()

	private var periodScrollView: some View {
		ZStack {
			ScrollView(.horizontal) {
				LazyHStack(spacing: 0) {
					ForEach(allPeriods.indices, id: \.self) { index in
						let period = allPeriods[index]
						periodCell(for: period, index: index)
							.id(index)
					}
				}
				.scrollTargetLayout()
			}
			.scrollTargetBehavior(.viewAligned)
			.scrollPosition($scrollPosition)
			.onAppear {


				selectedPeriod = .currentPeriod
				let ogPosition = ScrollPosition(x: CGFloat(selectedPeriod.index) * UIScreen.main.bounds.width)
				scrollPosition = ogPosition

				DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
					withAnimation(.easeInOut(duration: 2)) {
							// These values don't actually work, but I'll leave this here in case that changes
						scrollPosition = .init(x: ogPosition.x! - 250)
					}

					DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
						withAnimation(.easeInOut(duration: 1.5)) {
							scrollPosition = .init(x: ogPosition.x! + 250)

						}
					}
				}
			}
		}
	}

	private var tip: SwipeOnboardingTip {
		SwipeOnboardingTip(context: selectedPeriod.nameLowercased)
	}

	private func periodCell(for period: Period, index: Int) -> some View {
		ProduceList(
			selectedPeriod: period,
			parentTab: selectedTab,
			selectedCategory: $selectedCategory
		)
		.containerRelativeFrame(.horizontal)
//		.padding(.top, -100)
	}

	var body: some View {
		NavigationStack {
			periodScrollView
				.toolbar {
					if featureToggleHelper.isEnabled(.useToolbarButtons) {
//						InfiniteTabToolbar<Period>(
//							selectedPeriod: $selectedPeriod,
//							scrollPosition: $scrollPosition
//						)
					}
				}
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
			.environmentObject(FeatureToggleHelper())
	}
}

