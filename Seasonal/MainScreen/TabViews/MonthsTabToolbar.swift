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
	@Binding var selectedMonth: Month

	var body: some ToolbarContent {
		// <-
		ToolbarItem(placement: .navigationBarLeading) {
			Button {
				selectedMonth = selectedMonth.previous()
			} label: {
				Image.arrowLeft
			}
			.buttonStyle(.plain)
		}
		// Month name
		ToolbarItem(placement: .topBarLeading) {
			Text(selectedMonth.name)
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
						selectedMonth = month
					}
				}
			} label: {
				Label("Month", systemImage: "calendar")
					.glassEffect(.regular)
			}
			// ->
			Button{
				selectedMonth = selectedMonth.next()
			} label: {
				Image.arrowRight
			}
		}
	}
}
