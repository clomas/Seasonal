//
//  SelectMonthButton.swift
//  Seasonal
//
//  Created by Clint Thomas on 9/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

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
                .background(.ultraThinMaterial, in: Circle())
                .glassEffect(.regular)
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
