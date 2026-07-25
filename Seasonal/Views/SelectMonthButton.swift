//
//  SelectMonthButton.swift
//  Seasonal
//
//  Created by Clint Thomas on 9/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

/// A glass, circular button that opens a period picker (months/seasons) as a popover
/// anchored to the button.
///
/// It uses a `Button` + `.popover` rather than a `Menu` on purpose: a `Menu` dims the whole
/// screen while open, and the glass label samples that dimmed backdrop and turns grey until
/// the scrim fades on collapse. A popover doesn't dim, so the glass keeps its colour.
///
/// The picker content is supplied by the caller and is handed a `dismiss` closure so a
/// selection can close the popover (the `Menu`'s automatic dismiss-on-select replacement).
@available(iOS 26.0, *)
struct SelectMonthButton<MenuContent: View>: View {

    @ViewBuilder var menuContent: (_ dismiss: @escaping () -> Void) -> MenuContent

    @ScaledMetric(relativeTo: .title2) private var iconSize: CGFloat = 22

    @State private var isPresented = false

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            isPresented = true
        } label: {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: iconSize, weight: .medium))
                .frame(width: iconSize, height: iconSize)
                .padding(16)
                .glassEffect(.regular.interactive(), in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .tint(.primary)
        .accessibilityIdentifier("selectMonthButton")
        .accessibilityLabel("Select a month")
        .popover(
            isPresented: $isPresented,
            attachmentAnchor: .point(.bottom),
            arrowEdge: .top
        ) {
            menuContent { isPresented = false }
                .presentationCompactAdaptation(.popover)
        }
    }
}

@available(iOS 26.0, *)
#Preview {
    SelectMonthButton { _ in
        Text("January")
        Text("February")
        Text("March")
    }
}
