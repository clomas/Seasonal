//
//  MonthRangeOverlay.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

/// Capsules behind each run of consecutive in-season months; a run touching both December and
/// January extends past the edge so the wrap-around reads as continuous.
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

    private var wrapsAroundYearEnd: Bool {
        months.contains(.january) && months.contains(.december)
    }

    private var ranges: [ClosedRange<Int>] {
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
        var count = range.count
        var xOffset = CGFloat(range.lowerBound - 1) * monthWidth

        if range.lowerBound == 1 && wrapsAroundYearEnd {
            count += 1
            xOffset -= monthWidth
        }
        if range.upperBound == monthCount && wrapsAroundYearEnd {
            count += 1
        }

        return Capsule()
            .fill(Colour.capsuleFill)
            .overlay(Capsule().stroke(Colour.capsuleStroke, lineWidth: strokeWidth))
            .frame(width: CGFloat(count) * monthWidth, height: height)
            .offset(x: xOffset)
    }
}
