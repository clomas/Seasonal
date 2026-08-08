//
//  InfoButton.swift
//  Seasonal
//
//  Created by Clint Thomas on 15/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

/// A glass, circular info button matching `SelectMonthButton`, used as a top
/// overlay to present the in-app information screen.
@available(iOS 26.0, *)
struct InfoButton: View {

    let action: () -> Void

    @ScaledMetric(relativeTo: .title2) private var iconSize: CGFloat = 22

    var body: some View {
        Button(action: action) {
            Image(systemName: "info.circle")
                .font(.system(size: iconSize, weight: .medium))
                .frame(width: iconSize, height: iconSize)
                .padding(16)
                // Matches SelectMonthButton exactly: one interactive glass circle. This used to
                // stack .ultraThinMaterial under a shapeless .glassEffect, which defaulted to a
                // capsule and made the two chrome buttons read as different controls.
                .glassEffect(.regular.interactive(), in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .tint(.primary)
        .accessibilityIdentifier("infoButton")
        .accessibilityLabel("App information")
    }
}

@available(iOS 26.0, *)
#Preview {
    InfoButton {}
}
