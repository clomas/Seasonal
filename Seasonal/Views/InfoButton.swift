//
//  InfoButton.swift
//  Seasonal
//
//  Created by Clint Thomas on 15/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26.0, *)
struct InfoButton: View {

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: Symbol.info)
        }
        .tint(.primary)
        .accessibilityIdentifier("infoButton")
        .accessibilityLabel(Strings.Info.button)
    }
}

@available(iOS 26.0, *)
#Preview {
    InfoButton {}
}
