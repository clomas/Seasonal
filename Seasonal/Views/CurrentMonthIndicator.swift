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

    var body: some View {
        ZStack {
            Circle()
                .fill(isInSeason ? Colour.accent : .secondary)
                .frame(width: diameter, height: diameter)
            Text(letter)
                .font(.label)
                .foregroundStyle(Colour.onAccent)
        }
    }
}

#Preview {
    HStack {
        CurrentMonthIndicator(letter: "S", isInSeason: true, diameter: .capsuleRowHeight)
        CurrentMonthIndicator(letter: "S", isInSeason: false, diameter: .capsuleRowHeight)
    }
}
