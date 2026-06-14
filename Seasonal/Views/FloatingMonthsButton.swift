//
//  FloatingMonthsButton.swift
//  Seasonal
//
//  Created by Clint Thomas on 9/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26.0, *)
struct FloatingMonthsButton: View {

    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            Image(systemName: "calendar")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.primary)
                .padding(16)
                .background(.ultraThinMaterial, in: Circle())
                .glassEffect(.regular)
        }
        .foregroundStyle(.primary)
        .accessibilityIdentifier("pickMonthButton")
        .accessibilityLabel("Pick a month")
    }
}

@available(iOS 26.0, *)
#Preview {
    FloatingMonthsButton(action: {})
}
