//
//  SettingsButton.swift
//  Seasonal
//
//  Created by Clint Thomas on 15/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26.0, *)
struct SettingsButton: View {

    let action: () -> Void

    var body: some View {
        Button(Strings.Info.button, systemImage: Symbol.settings, action: action)
            .tint(.primary)
            .accessibilityIdentifier("settingsButton")
    }
}

@available(iOS 26.0, *)
#Preview {
    SettingsButton {}
}
