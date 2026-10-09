//
//  CurrentMonthIndicator.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

struct CurrentMonthIndicator: View {

    let letter: String
    let isInSeason: Bool
    let diameter: CGFloat

    private let ringWidth: CGFloat = 1.5

    var body: some View {
        ZStack {
            // Out of season is a ring, not a grey fill: onAccent text on grey fails WCAG AA in light mode.
            Circle()
                .fill(isInSeason ? Colour.accent : .clear)
                .stroke(isInSeason ? .clear : Color.secondary, lineWidth: ringWidth)
                .frame(width: diameter, height: diameter)
            Text(letter)
                .font(.label)
                .foregroundStyle(isInSeason ? Colour.onAccent : .primary)
        }
    }
}

#Preview {
    HStack {
        CurrentMonthIndicator(letter: "S", isInSeason: true, diameter: .capsuleRowHeight)
        CurrentMonthIndicator(letter: "S", isInSeason: false, diameter: .capsuleRowHeight)
    }
}
