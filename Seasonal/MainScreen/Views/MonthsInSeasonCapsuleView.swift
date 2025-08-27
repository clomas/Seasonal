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

	var body: some View {
		GeometryReader { geometry in
			let totalWidth = geometry.size.width

			ZStack(alignment: .leading) {
					// Overlay range (e.g. March to July)
				MonthRangeOverlay(months: months, totalWidth: totalWidth)

					// Month circles
				HStack(spacing: 0) {
					ForEach(Months.allCases, id: \.self) { month in
						ZStack {
							if DateHandler().findMonthAndSeason().month == month {
								ZStack {
									Circle()
										.fill(Colour.inSeason)
										.frame(width: 30, height: 30)
									Text(month.firstLetter)
										.foregroundColor(.white)
										.font(.subheadline)
								}
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
		.frame(height: 30)
	}
}

struct MonthRangeOverlay: View {
	let months: [Months]
	let totalWidth: CGFloat

		// Build contiguous ranges from the selected months (e.g. [1,2,3], [9,10], [12])
	private var ranges: [(start: Int, end: Int)] {
		let set = Set(months.map { $0.rawValue })   // assumes Months.rawValue is 1...12
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
			ForEach(Array(ranges.enumerated()), id: \.offset) { _, range in
				let count = range.end - range.start + 1
				let overlayWidth = CGFloat(count) * monthWidth - 4   // small inset so edges don’t touch
				let xOffset = CGFloat(range.start - 1) * monthWidth

				if #available(iOS 26.0, *) {
					Capsule()
						.fill(Colour.inSeason.opacity(0.25))
						.overlay(
							Capsule()
								.stroke(Colour.inSeason.opacity(0.5), lineWidth: 1)
						)
						.frame(width: overlayWidth, height: 30)
						.offset(x: xOffset)
				} else {
					Capsule()
						.fill(Colour.inSeason.opacity(0.25))
						.overlay(
							Capsule()
								.stroke(Colour.inSeason.opacity(0.8), lineWidth: 1)
						)
						.frame(width: overlayWidth, height: 30)
						.offset(x: xOffset)
				}
			}
		}
	}
}
//struct MonthRangeOverlay: View {
//	let months: [Months]
//	let totalWidth: CGFloat
//
//	private var offset: CGFloat {
//		let currentMonth = DateHandler().currentMonth
//
//		return months.contains(currentMonth) ? 4 : 0
//	}
//
//	var body: some View {
//		guard let minMonth = months.min(by: { $0.rawValue < $1.rawValue }),
//			  let maxMonth = months.max(by: { $0.rawValue < $1.rawValue }) else {
//			return AnyView(EmptyView())
//		}
//
//		let startIndex = minMonth.rawValue - 1
//		let endIndex = maxMonth.rawValue
//		let monthWidth = totalWidth / 12
//		let overlayWidth = CGFloat(endIndex - startIndex) * monthWidth
//		let xOffset = CGFloat(startIndex) * monthWidth
//
//		if #available(iOS 26.0, *) {
//			return AnyView(
//				Capsule()
//					.fill(Colour.inSeason.opacity(0.25))
//					.overlay(
//						Capsule()
//							.stroke(Colour.inSeason.opacity(0.5), lineWidth: 1)
//						//							.glassEffect(.regular)
//					)
//					.frame(width: overlayWidth - offset, height: 30)
//					.offset(x: xOffset)
//				//					.shadow(radius: 20)
//			)
//
//		} else {
//			return AnyView(
//				Capsule()
//					.fill(Colour.inSeason.opacity(0.25))
//					.overlay(
//						Capsule()
//							.stroke(Colour.inSeason.opacity(0.8), lineWidth: 1)
//					)
//					.frame(width: overlayWidth - 4, height: 30)
//					.offset(x: xOffset)
//				//					.shadow(radius: 20)
//			)
//		}
//	}
//}

#Preview {
	VStack {
		MonthsInSeasonCapsuleView(months: [.january])
		MonthsInSeasonCapsuleView(months: [.january, .march, .june])
		MonthsInSeasonCapsuleView(months: [.january, .february, .march, .september, .october, .december])
	}
}
