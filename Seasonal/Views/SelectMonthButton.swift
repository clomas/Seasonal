//
//  SelectMonthButton.swift
//  Seasonal
//
//  Created by Clint Thomas on 9/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

/// A glass, circular calendar button that opens a menu of the supplied items
/// (e.g. months/seasons) anchored to the button.
@available(iOS 26.0, *)
struct SelectMonthButton<MenuContent: View>: View {

    @ViewBuilder var menuContent: () -> MenuContent

    @ScaledMetric(relativeTo: .title2) private var iconSize: CGFloat = 22

    var body: some View {
        Menu {
            menuContent()
        } label: {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: iconSize, weight: .medium))
                .frame(width: iconSize, height: iconSize)
                .padding(16)
                .background(.ultraThinMaterial, in: Circle())
                .glassEffect(.regular)
        }
        .tint(.primary)
        .accessibilityIdentifier("selectMonthButton")
        .accessibilityLabel("Select a month")
    }
}

@available(iOS 26.0, *)
#Preview {
    SelectMonthButton {
        Button("January") {}
        Button("February") {}
        Button("March") {}
    }
}
