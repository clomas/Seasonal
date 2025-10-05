//
//  PeriodTabView.swift
//  Seasonal
//
//  Created by Clint Thomas on 19/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI
import TipKit

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
	@State private var showTip: Bool = !GlobalSettings.swipeTipShown.swipe

	var body: some View {
		NavigationStack {
			periodScrollView
				.overlay {
					if showTip {
						TipView(tip)
							.transition(AnyTransition.opacity.combined(with: AnyTransition.scale))
							.onAppear {
								withAnimation(.easeInOut(duration: 2)) {
									showTip = false
								}
							}
					}
				}
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

	private var periodScrollView: some View {
		GeometryReader { proxy in
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
					let ogPosition: ScrollPosition = ScrollPosition(x: CGFloat(selectedPeriod.index) * UIScreen.main.bounds.width)
					let ogXPosition: CGFloat = ogPosition.x ?? 0
					scrollPosition = ogPosition

					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						withAnimation(.easeInOut(duration: 2)) {
							// These should be smaller "peek" values but they don't actually work
							scrollPosition = .init(x: ogXPosition - proxy.size.width)
						}

						DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
							withAnimation(.easeInOut(duration: 1.5)) {
								scrollPosition = .init(x: ogXPosition + proxy.size.width * 2)
							}

							DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
								withAnimation(.easeInOut(duration: 2)) {
									scrollPosition = .init(x: ogXPosition - proxy.size.width)
								}
							}
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
		.environmentObject(appCoordinator)
//		.padding(.top, -100)
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
