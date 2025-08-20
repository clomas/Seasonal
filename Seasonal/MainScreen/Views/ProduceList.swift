	//
	//  ProduceList.swift
	//  Seasonal
	//
	//  Created by Clint Thomas on 27/7/2025.
	//  Copyright © 2025 Clint Thomas. All rights reserved.
	//

import SwiftUI

struct ProduceList: View {
	let produce: [ProduceModel]
	let period: any PeriodType
	// TODO: Delete this
//	let selectedTab: MainTabScreen.Tabs

	var body: some View {
		ZStack {
			Colour.background.ignoresSafeArea()

			if produce.isEmpty {
				emptyProduceListView
					.padding(.bottom, .largePadding)
			} else {
				List(produce, id: \.id) { item in
					ProduceCell(produce: item)
						.listRowSeparator(.hidden)
						.listRowInsets(.topListRowInset)
						.listRowBackground(Color.clear)

				}
				.listStyle(.plain)
				.scrollContentBackground(.hidden)
				.scrollIndicators(.hidden)
				.safeAreaInset(edge: .bottom) {
					Color.clear.frame(height: .largePadding)
				}
			}
		}
	}

	private var emptyProduceListView: some View {
		VStack(spacing: 6) {
			Image.settings
				.resizable()
				.frame(width: 50, height: 50)
				.padding(20)
			Text("Nothing to see ere, try another \(period.nameLowercased)") // TODO: Test this out
		}
	}
}
