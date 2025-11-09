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

	private let overlayFrame: CGFloat = 30

	private var thisMonth: Months {
		Months.currentPeriod
	}

	private var isThisMonthInSeason: Bool {
		months.contains(thisMonth)
	}

	var body: some View {
		GeometryReader { geometry in
			let totalWidth = geometry.size.width

			ZStack(alignment: .leading) {
				MonthRangeOverlay(months: months, totalWidth: totalWidth, overlayFrame: overlayFrame)
				HStack(spacing: 0) {
					ForEach(Months.allCases, id: \.self) { month in
						ZStack {
							if thisMonth == month && isThisMonthInSeason {
								currentMonthView(firstLetter: month.firstLetter, fill: Colour.inSeason)
							} else if thisMonth == month {
								currentMonthView(firstLetter: month.firstLetter, fill: .gray)
							} else {
								Text(month.firstLetter)
									.font(.subheadline)
							}
						}
						.frame(width: totalWidth / 12)
					}
				}
			}
		}
		.frame(height: overlayFrame)
	}

	func currentMonthView(firstLetter: String, fill: Color) -> some View {
		ZStack {
			Circle()
				.fill(fill)
				.frame(width: overlayFrame + 1, height: overlayFrame + 1)
			Text(firstLetter)
				.foregroundColor(.white)
				.font(.subheadline)
		}
	}

	struct MonthRangeOverlay: View {
		let months: [Months]
		let totalWidth: CGFloat
		let overlayFrame: CGFloat

		private var ranges: [(start: Int, end: Int)] {
			let set = Set(months.map { $0.rawValue })
			guard !set.isEmpty else { return [] }

			var result: [(start: Int, end: Int)] = []
			var i = 1
			while i <= 12 {
				if set.contains(i) {
					var j = i
					while j + 1 <= 12 && set.contains(j + 1) { j += 1 }
					result.append((start: i, end: j))
					i = j + 1
				} else {
					i += 1
				}
			}
			return result
		}

		var body: some View {
			let monthWidth = totalWidth / 12
			ZStack(alignment: .leading) {
				ForEach(ranges, id: \.start) { range in
					overlayCapsule(for: range, monthWidth: monthWidth)
				}
			}
		}

			// Add this as a private method in your struct
		private func overlayCapsule(for range: (start: Int, end: Int), monthWidth: CGFloat) -> some View {
			var count = range.end - range.start + 1
			var xOffset = CGFloat(range.start - 1) * monthWidth

			if range.start == 1 && months.contains(.january) && months.contains(.december) {
				count += 1
				xOffset -= monthWidth
			}
			if range.end == 12 && months.contains(.january) && months.contains(.december) {
				count += 1
			}

			let overlayWidth = CGFloat(count) * monthWidth

			return Capsule()
				.fill(Colour.inSeason.opacity(0.25))
				.overlay(
					Capsule()
						.stroke(Colour.inSeason.opacity(0.5), lineWidth: 1)
				)
				.frame(width: overlayWidth, height: overlayFrame)
				.offset(x: xOffset)
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
