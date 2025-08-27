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
	@State private var showGuide = true

	private var periodScrollView: some View {
		ScrollView(.horizontal) {
			LazyHStack(spacing: 0) {
				ForEach(allPeriods.indices, id: \.self) { index in
					let period = allPeriods[index]
					periodCell(for: period, index: index)
						.id(index)
				}
//					.frame(width: geo.size.height, height: geo.size.height)
			}
			.scrollTargetLayout()
		}
		.scrollTargetBehavior(.viewAligned)
		.scrollPosition($scrollPosition)
		.onAppear {
			showGuide = true
//			selectedPeriod = .currentPeriod
			let ogPosition = ScrollPosition(x: CGFloat(selectedPeriod.index) * UIScreen.main.bounds.width)
			scrollPosition = ogPosition

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
				withAnimation(.easeInOut(duration: 2)) {
					// These values don't actually work, but I'll leave this here in case that changes
					scrollPosition = .init(x: ogPosition.x! - 250)
				}

				DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
					withAnimation(.easeInOut(duration: 1)) {
						scrollPosition = .init(x: ogPosition.x! + 250)
						showGuide = false
					}

//					DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
//						withAnimation(.easeInOut(duration: 0.5)) {
//							scrollPosition = ScrollPosition(x: CGFloat(selectedPeriod.index) * UIScreen.main.bounds.width)
//						}
//					}
				}
			}
		}
		.popoverTip(SwipeOnboardingTip(context: selectedPeriod.nameLowercased), isPresented: $showGuide)
	}

	private func periodCell(for period: Period, index: Int) -> some View {
		ProduceList(
			selectedPeriod: period,
			parentTab: selectedTab,
			selectedCategory: $selectedCategory
		)
		.containerRelativeFrame(.horizontal)
		.padding(.top, -100)
		.onAppear { print("Cell appeared at index \(index)") } // TODO: Delete
		.onDisappear { print("Cell disappeared at index \(index)") }
	}

	var body: some View {
		NavigationView {
			periodScrollView
				.ignoresSafeArea(edges: .bottom)
				.onAppear {
					selectedPeriod = .currentPeriod
					scrollPosition = ScrollPosition(x: CGFloat(selectedPeriod.index) * UIScreen.main.bounds.width)

					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						withAnimation(.easeInOut(duration: 0.5)) {
							scrollPosition = ScrollPosition(x: scrollPosition.x! - 150)
						}

						DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
							withAnimation(.easeInOut(duration: 0.5)) {
								scrollPosition = ScrollPosition(x: scrollPosition.x! + 150)
							}

							DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
								withAnimation(.easeInOut(duration: 0.5)) {
									scrollPosition = ScrollPosition(x: CGFloat(selectedPeriod.index) * UIScreen.main.bounds.width)
								}
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
	}
}

