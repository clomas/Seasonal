//
//  MonthsInSeasonCapsuleView.swift
//  Seasonal
//
//  Created by Clint Thomas on 12/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

struct MonthsInSeasonCapsuleView: View {

	let from: Month = .january
	let to: Month = .september

	var body: some View {
		GeometryReader { geometry in
			let totalWidth = geometry.size.width

			ZStack(alignment: .leading) {
					// Overlay range (e.g. March to July)
				MonthRangeOverlay(from: from, to: to, totalWidth: totalWidth)

					// Month circles
				HStack(spacing: 0) {
					ForEach(Month.allCases, id: \.self) { month in
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
	let from: Month
	let to: Month
	let totalWidth: CGFloat

	private var offset: CGFloat {
		let currentMonth = DateHandler().currentMonth

		return currentMonth == to || currentMonth == from ? 4 : 0
	}

	var body: some View {
		let startIndex = from.rawValue - 1
		let endIndex = to.rawValue + 1
		let monthWidth = totalWidth / 12
		let overlayWidth = CGFloat(endIndex - startIndex) * monthWidth
		let xOffset = CGFloat(startIndex) * monthWidth

		if #available(iOS 26.0, *) {
			return Capsule()
				.fill(Colour.inSeason.opacity(0.25))
				.overlay(
					Capsule()
						.stroke(Colour.inSeason.opacity(0.5), lineWidth: 1)
//						.glassEffect(.regular)
				)

				.frame(width: overlayWidth - offset, height: 30)
				.offset(x: xOffset)
//				.shadow(radius: 20)

		} else {
			return Capsule()
				.fill(Colour.inSeason.opacity(0.25))
				.overlay(
					Capsule()
						.stroke(Colour.inSeason.opacity(0.8), lineWidth: 1)
				)
				.frame(width: overlayWidth - 4, height: 30)
				.offset(x: xOffset)
//				.shadow(radius: 20)
		}
	}
}

#Preview {
	MonthsInSeasonCapsuleView()
}
