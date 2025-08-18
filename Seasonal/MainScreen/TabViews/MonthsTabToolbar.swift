	//
	//  MonthsTabToolbar.swift
	//  Seasonal
	//
	//  Created by Clint Thomas on 17/8/2025.
	//  Copyright © 2025 Clint Thomas. All rights reserved.
	//

import SwiftUI

struct MonthsTabToolbar: ToolbarContent {
		//	@Binding var currentMonth: Month
	@Binding var scrollPosition: Int

	let middleOffset: Int
	let selectedTab: Binding<MainTabScreen.Tabs>

	var body: some ToolbarContent {
		ToolbarItem(placement: .navigationBarLeading) {
			Button {
				if case let .months(month, category, search) = selectedTab.wrappedValue {
					let newMonth = month.previous()
					selectedTab.wrappedValue = .months(newMonth, category: category, search: search)
					let newIndex = getMonthIndex(newMonth) + middleOffset
					withAnimation(.easeInOut(duration: 0.4)) {
						scrollPosition = newIndex
					}
				}
			} label: {
				Image(systemName: "arrow.left")
			}
		}

		ToolbarItem(placement: .topBarLeading) {
			Text(selectedTab.wrappedValue.title)
				.font(.title)
				.fixedSize()
		}
		.sharedBackgroundVisibility(.hidden)

		ToolbarItemGroup(placement: .navigationBarTrailing) {
			monthMenu()
			Button {
				if case let .months(month, category, search) = selectedTab.wrappedValue {
					let newMonth = month.next()
					selectedTab.wrappedValue = .months(newMonth, category: category, search: search)
					let newIndex = getMonthIndex(newMonth) + middleOffset
					withAnimation(.easeInOut(duration: 0.4)) {
						scrollPosition = newIndex
					}
				}
			} label: {
				Image(systemName: "arrow.right")
			}
		}
	}

	private func getMonthIndex(_ month: Month) -> Int {
		Month.allCases.firstIndex(of: month) ?? 0
	}

	private func monthMenu() -> some View {
		Menu {
			ForEach(Month.allCases, id: \.self) { month in
				Button(month.name) {
					if case let .months(_, currentCategory, search) = selectedTab.wrappedValue {
						selectedTab.wrappedValue = .months(month, category: currentCategory, search: search)
						let newIndex = getMonthIndex(month) + middleOffset
						withAnimation(.easeInOut(duration: 0.4)) {
							scrollPosition = newIndex
						}
					}
				}
			}
		} label: {
			Label("Month", systemImage: "calendar")
				.glassEffect(.regular)
		}
	}
}
