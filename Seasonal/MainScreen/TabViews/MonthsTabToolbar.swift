	//
	//  MonthsTabToolbar.swift
	//  Seasonal
	//
	//  Created by Clint Thomas on 17/8/2025.
	//  Copyright © 2025 Clint Thomas. All rights reserved.
	//

import SwiftUI

struct MonthsTabToolbar: ToolbarContent {

	@Binding var scrollPosition: Int

	let middleOffset: Int
	let selectedTab: Binding<Tabs>

	var body: some ToolbarContent {
		// <-
		ToolbarItem(placement: .navigationBarLeading) {
			Button {
				selectedTab.wrappedValue = selectedTab.wrappedValue.updatingMonth(selectedTab.wrappedValue.currentSelectedMonth.previous())
			} label: {
				Image.arrowLeft
			}
		}
		// Month name
		ToolbarItem(placement: .topBarLeading) {
			Text(selectedTab.wrappedValue.title)
				.font(.title)
				.fixedSize()
		}
		.sharedBackgroundVisibility(.hidden)

		// (🗓️ ->)
		ToolbarItemGroup(placement: .navigationBarTrailing) {
			// 🗓️ picker
			Menu {
				ForEach(Month.allCases, id: \.self) { month in
					Button(month.name) {
						selectedTab.wrappedValue = selectedTab.wrappedValue.updatingMonth(month)
					}
				}
			} label: {
				Label("Month", systemImage: "calendar")
					.glassEffect(.regular)
			}
			// ->
			Button{
				selectedTab.wrappedValue = selectedTab.wrappedValue.updatingMonth(selectedTab.wrappedValue.currentSelectedMonth.next())
			} label: {
				Image.arrowRight
			}
		}
	}
}
