//
//  InfoButton.swift
//  Seasonal
//
//  Created by Clint Thomas on 15/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

/// Toolbar button that presents the in-app information screen.
@available(iOS 26.0, *)
struct InfoButton: View {

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "info.circle")
        }
        .tint(.primary)
        .accessibilityIdentifier("infoButton")
        .accessibilityLabel("App information")
    }
}

@available(iOS 26.0, *)
#Preview {
    InfoButton {}
}
