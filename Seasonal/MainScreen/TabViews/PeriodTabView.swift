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
	@State private var selectedIndex: Int?
	@State private var baseIndex: Int = 0
	@State private var isPeeking: Bool = false
	@State private var peekTask: Task<Void, Never>?
	
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
	
	private var periodScrollView: some View {
		GeometryReader { _ in
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
				.scrollPosition(id: $selectedIndex)
				.disabled(isPeeking)
				.onAppear {
					performIntroAnimation()
				}
				.onDisappear {
					peekTask?.cancel()
					isPeeking = false
				}
			}
		}
	}
	
	private func performIntroAnimation() {
		selectedPeriod = .currentPeriod
		baseIndex = selectedPeriod.index
		selectedIndex = baseIndex
		
		isPeeking = true
		
		peekTask?.cancel()
		let periodCount = allPeriods.count
		peekTask = Task { @MainActor in
			func clamp(_ i: Int) -> Int {
				min(max(i, 0), periodCount - 1)
			}
			
			try? await Task.sleep(nanoseconds: 500_000_000)
			withAnimation(.easeInOut(duration: 2)) {
				selectedIndex = clamp(baseIndex - 1)
			}
			
			try? await Task.sleep(nanoseconds: 2_500_000_000)
			withAnimation(.easeInOut(duration: 1.5)) {
				selectedIndex = clamp(baseIndex + 1)
			}
			
			try? await Task.sleep(nanoseconds: 2_000_000_000)
			withAnimation(.easeInOut(duration: 2)) {
				selectedIndex = baseIndex
			}
			
			isPeeking = false
		}
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
