	//
	//  MonthsInSeasonCapsuleView.swift
	//  Seasonal
	//
	//  Created by Clint Thomas on 12/7/2025.
	//  Copyright © 2025 Clint Thomas. All rights reserved.
	//

import SwiftUI

struct MonthsInSeasonCapsuleView: View {

	let months: [Months]

	private let rowHeight: CGFloat = .capsuleRowHeight
	private let indicatorOverhang: CGFloat = 1
	private let thisMonth = Months.currentPeriod

	var body: some View {
		GeometryReader { geometry in
			let totalWidth = geometry.size.width

			ZStack(alignment: .leading) {
				MonthRangeOverlay(months: months, totalWidth: totalWidth, height: rowHeight)
				HStack(spacing: 0) {
					ForEach(Months.allCases, id: \.self) { month in
						monthLabel(for: month)
							.frame(width: totalWidth / CGFloat(Months.allCases.count))
					}
				}
			}
		}
		.frame(height: rowHeight)
	}

	@ViewBuilder
	private func monthLabel(for month: Months) -> some View {
		if month == thisMonth {
			CurrentMonthIndicator(
				letter: month.firstLetter,
				isInSeason: months.contains(month),
				diameter: rowHeight + indicatorOverhang
			)
		} else {
			Text(month.firstLetter)
				.font(.label)
				.foregroundStyle(months.contains(month) ? Color.primary : .secondary)
		}
	}
}

#Preview {
	VStack {
		MonthsInSeasonCapsuleView(months: [.january])
		MonthsInSeasonCapsuleView(months: [.january, .march, .june])
		MonthsInSeasonCapsuleView(months: [.january, .february, .march, .june, .august, .september, .october, .december])
	}
}
