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
        case list      // leading-aligned, fills available width — for selection lists
        case prominent // hugging, centered — for primary CTAs
    }

    let label: String
    let systemImage: String
    var style: Style = .list
    let tapHandler: Closure

    var body: some View {
        Button(action: tapHandler) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Colour.inSeason)
                Text(label)
                    .font(.headline)
                    .foregroundStyle(.primary)
                if style == .list {
                    Spacer(minLength: 0)
                }
            }
            .padding(.horizontal, style == .list ? 20 : 28)
            .padding(.vertical, 14)
            .frame(maxWidth: style == .list ? 340 : nil)
            .glassEffect(
                .regular.tint(Colour.inSeason.opacity(style == .list ? 0.35 : 0.45)).interactive(),
                in: Capsule()
            )
        }
        .buttonStyle(.plain)
    }
}
