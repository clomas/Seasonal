//
//  AccentIconChip.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

struct AccentIconChip: View {

    let systemImage: String
    var diameter: CGFloat = .iconChip

    private let glyphScale: CGFloat = 0.5

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: diameter * glyphScale, weight: .semibold))
            .foregroundStyle(Colour.onAccent)
            .frame(width: diameter, height: diameter)
            .background(Circle().fill(Colour.accent))
    }
}

#Preview {
    HStack(spacing: .space4) {
        AccentIconChip(systemImage: Symbol.location)
        AccentIconChip(systemImage: Symbol.retry)
    }
}
