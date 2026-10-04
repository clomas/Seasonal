//
//  DesignSystem.swift
//  Seasonal
//
//  Created by Clint Thomas on 27/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

// MARK: - Typography

extension Font {
    static let sectionTitle = Font.title3.weight(.semibold)
    static let cardTitle = Font.title2
    static let buttonLabel = Font.headline
    static let bodyText = Font.body
    static let label = Font.subheadline
}

// MARK: - Spacing

extension CGFloat {
    static let space1: CGFloat = 4
    static let space2: CGFloat = 8
    static let space3: CGFloat = 12
    static let space4: CGFloat = 16
    static let space5: CGFloat = 20
    static let space6: CGFloat = 24
    static let space8: CGFloat = 32

    static let iconChip: CGFloat = 28
    static let minimumTapTarget: CGFloat = 44
    static let capsuleRowHeight: CGFloat = 30
    static let largePadding: CGFloat = 200
}

#Preview {
    VStack(spacing: .space4) {
        Text("sectionTitle").font(.sectionTitle)
        Text("cardTitle").font(.cardTitle)
        Text("buttonLabel").font(.buttonLabel)
        Text("bodyText").font(.bodyText)
        Text("label").font(.label)
    }
    .padding()
}
