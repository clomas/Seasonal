//
//  TintedGlassCapsuleButton.swift
//  Seasonal
//
//  Created by Clint Thomas on 10/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26.0, *)
struct TintedGlassCapsuleButton: View {

    enum Style {
        /// Leading-aligned and full width, for selection lists.
        case list
        /// Hugs its content, for primary calls to action.
        case prominent
    }

    let label: String
    let systemImage: String
    var style: Style = .list
    let action: () -> Void

    private let listMaxWidth: CGFloat = 340
    private let listTintOpacity = 0.35
    private let prominentTintOpacity = 0.45

    var body: some View {
        Button(action: action) {
            HStack(spacing: .space3) {
                AccentIconChip(systemImage: systemImage)
                Text(label)
                    .font(.buttonLabel)
                    .foregroundStyle(.primary)
                if style == .list {
                    Spacer(minLength: 0)
                }
            }
            .padding(.horizontal, style == .list ? .space5 : .space8)
            .padding(.vertical, .space4)
            .frame(maxWidth: style == .list ? listMaxWidth : nil)
            .glassEffect(
                .regular.tint(Colour.inSeason.opacity(style == .list ? listTintOpacity : prominentTintOpacity)).interactive(),
                in: Capsule()
            )
        }
        .buttonStyle(.plain)
    }
}
