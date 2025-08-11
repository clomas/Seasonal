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

	private let category: ViewDisplayed.ProduceCategory = .all
	private let middleOffset = Month.allCases.count

	@Binding var selectedTab: MainTabScreen.Tabs
	@State private var currentMonth: Month = .august // or from selectedTab
	@State private var scrollTarget: Int = Month.allCases.count

	private var infiniteMonths: [Month] {
		Array(repeating: Month.allCases, count: 3).flatMap { $0 }
	}

	private func produce(for month: Month) -> [ProduceModel] {
		produce.filtered(by: .months(month, category: category), produce: produce)
	}

	var body2: some View {
		ScrollViewReader { proxy in
			ScrollView(.horizontal, showsIndicators: false) {
				LazyHStack(spacing: 0) {
					ForEach(infiniteMonths.indices, id: \.self) { index in
						let month = infiniteMonths[index]
						ProduceList(produce: produce(for: month))
//							.frame(width: UIScreen.main.bounds.width)
							.tag(index)
							.navigationTitle(month.name)
					}
				}
			}
			.content.offset(x: 0) // fixes bounce
			.onAppear {
				proxy.scrollTo(scrollTarget, anchor: .center)
			}
			.gesture(
				DragGesture().onEnded { value in
					let direction = value.translation.width < 0 ? 1 : -1
					scrollTarget += direction
					withAnimation {
						proxy.scrollTo(scrollTarget, anchor: .center)
					}
					let realIndex = scrollTarget % Month.allCases.count
					let newMonth = Month.allCases[realIndex]
					currentMonth = newMonth
					selectedTab = .months(newMonth, category: category)
				}
			)
		}
		.toolbar {
			ToolbarItem(placement: .navigationBarLeading) {
				Button {
					scrollTarget += -1
				} label: {
					Image(systemName: "chevron.left")
				}
			}
			ToolbarItemGroup(placement: .navigationBarTrailing) {
				monthMenu()
				Button {
					scrollTarget += 1
				} label: {
					Image(systemName: "chevron.right")
				}
			}
		}
	}

	var body3: some View {
		ZStack {
			ForEach(Month.allCases, id: \.self) { month in
				ProduceList(produce: produce(for: currentMonth))
					.tag(currentMonth)
					.navigationTitle(currentMonth.name)
					.ignoresSafeArea(edges: .bottom) // allow scroll to extend
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.tabViewStyle(.page(indexDisplayMode: .never))
		.animation(.easeInOut, value: currentMonth)
		.onChange(of: currentMonth) { _, newMonth in
			selectedTab = .months(newMonth, category: category)
		}
		.onAppear {
			if case let .months(month, _, _) = selectedTab {
				currentMonth = month
			}
		}
		.toolbar {
			ToolbarItem(placement: .navigationBarLeading) {
				Button {
					currentMonth = currentMonth.previous()
				} label: {
					Image(systemName: "arrow.left")
				}
			}
			ToolbarItemGroup(placement: .navigationBarTrailing) {
				monthMenu()
				Button {
					currentMonth = currentMonth.next()
				} label: {
					Image(systemName: "arrow.right")
				}
				.glassEffect(.regular)
			}
		}
	}

//	init(produce: [ProduceModel], selectedTab: MainTabScreen.Tabs) {
//		self.produce = produce
//		self.selectedTab = selectedTab
//		UITabBar.appearance().backgroundColor = .clear
////		UITabBar.appearance().unselectedItemTintColor = .darkGray
//	}

	var body: some View {
		VStack {
			TabView(selection: $currentMonth) {
				ForEach(Month.allCases, id: \.self) { month in
					ProduceList(produce: produce(for: month))
						.tag(month)
						.navigationTitle(month.name)
						.frame(maxWidth: .infinity, maxHeight: .infinity)
				}
			}
			.tabViewStyle(.page(indexDisplayMode: .never))
			.ignoresSafeArea(edges: .bottom)
			.animation(.easeInOut, value: currentMonth)
			.onChange(of: currentMonth) { _, newMonth in
				selectedTab = .months(newMonth, category: category)
			}
			.onAppear {
				if case let .months(month, _, _) = selectedTab {
					currentMonth = month
				}
			}
		}
		.toolbar {
			ToolbarItem(placement: .navigationBarLeading) {
				Button {
					currentMonth = currentMonth.previous()
				} label: {
					Image(systemName: "arrow.left")
				}
			}
			ToolbarItemGroup(placement: .navigationBarTrailing) {
				monthMenu()
				Button {
					currentMonth = currentMonth.next()
				} label: {
					Image(systemName: "arrow.right")
				}
				.glassEffect(.regular)
			}
		}
	}

	private func monthMenu() -> some View {
		Menu {
			ForEach(Month.allCases, id: \.self) { month in
				Button(month.name) {
					currentMonth = month
					selectedTab = .months(month, category: category)
				}
			}
		} label: {
			Label("Month", systemImage: "calendar")
				.glassEffect(.regular)
		}
	}
}
