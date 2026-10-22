//
//  MonthRangeOverlay.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

/// Capsules behind each run of consecutive in-season months. Each end is a true semicircle centred
/// on its month, so the current-month circle sits exactly over it.
struct MonthRangeOverlay: View {

    let months: [Months]
    let totalWidth: CGFloat
    let height: CGFloat

    private let strokeWidth: CGFloat = 1
    private let monthCount = Months.allCases.count

    var body: some View {
        ZStack(alignment: .leading) {
            ForEach(ranges, id: \.lowerBound) { range in
                capsule(for: range)
            }
        }
    }

    private var monthWidth: CGFloat {
        totalWidth / CGFloat(monthCount)
    }

    private var ranges: [ClosedRange<Int>] {
        Self.ranges(of: months)
    }

    /// Runs of consecutive month numbers (1 = January), in order.
    static func ranges(of months: [Months]) -> [ClosedRange<Int>] {
        let monthCount = Months.allCases.count
        let inSeason = Set(months.map(\.rawValue))
        var result: [ClosedRange<Int>] = []
        var index = 1

        while index <= monthCount {
            guard inSeason.contains(index) else {
                index += 1
                continue
            }
            var end = index
            while end < monthCount && inSeason.contains(end + 1) {
                end += 1
            }
            result.append(index...end)
            index = end + 1
        }
        return result
    }

    private func capsule(for range: ClosedRange<Int>) -> some View {
        let firstMonth = CGFloat(range.lowerBound - 1)
        let lastMonth = CGFloat(range.upperBound - 1)

        return Capsule(style: .circular)
            .fill(Colour.capsuleFill)
            .stroke(Colour.capsuleStroke, lineWidth: strokeWidth)
            .frame(width: (lastMonth - firstMonth) * monthWidth + height, height: height)
            .offset(x: centre(ofMonth: firstMonth) - height / 2)
    }

    private func centre(ofMonth index: CGFloat) -> CGFloat {
        (index + 0.5) * monthWidth
    }
}
