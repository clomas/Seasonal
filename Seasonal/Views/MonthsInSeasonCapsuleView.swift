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

	private let overlayFrame: CGFloat = .capsuleRowHeight

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
								currentMonthView(firstLetter: month.firstLetter)
							} else if thisMonth == month {
								currentMonthRing(firstLetter: month.firstLetter)
							} else {
								Text(month.firstLetter)
									.font(.label)
									.foregroundStyle(months.contains(month) ? Color.primary : .secondary)
							}
						}
						.frame(width: totalWidth / 12)
					}
				}
			}
		}
		.frame(height: overlayFrame)
	}

	/// The current month, when it *is* in season: a solid accent circle with an
	/// adaptive (`onAccent`) letter so it stays legible in light and dark mode.
	func currentMonthView(firstLetter: String) -> some View {
		ZStack {
			Circle()
				.fill(Colour.accent)
				.frame(width: overlayFrame + 1, height: overlayFrame + 1)
			Text(firstLetter)
				.foregroundColor(Colour.onAccent)
				.font(.label)
		}
	}

	/// The current month, when it is *not* in season: a light stroked ring rather
	/// than a heavy grey blob — reads as "today, but not in season".
	func currentMonthRing(firstLetter: String) -> some View {
		ZStack {
			Circle()
//				.strokeBorder(Color.secondary, lineWidth: 1.5)
                .fill(Color.secondary)
				.frame(width: overlayFrame + 1, height: overlayFrame + 1)
			Text(firstLetter)
                .foregroundColor(Colour.onAccent)
				.font(.label)
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
			var index = 1
            
			while index <= 12 {
				if set.contains(index) {
					var endIndex = index
                    
                    while endIndex + 1 <= 12 && set.contains(endIndex + 1) {
                        endIndex += 1
                    }
					result.append((start: index, end: endIndex))
                    index = endIndex + 1
                    
				} else {
                    index += 1
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
				.fill(Colour.capsuleFill)
				.overlay(
					Capsule()
						.stroke(Colour.capsuleStroke, lineWidth: 1)
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
