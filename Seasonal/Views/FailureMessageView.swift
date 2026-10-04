//
//  FailureMessageView.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct FailureMessageView: View {

    let title: String
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack {
            Text(title)
                .font(.sectionTitle)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            Text(message)
                .font(.bodyText)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()

            TintedGlassCapsuleButton(
                label: Strings.Launch.tryAgain,
                systemImage: Symbol.retry,
                style: .prominent,
                action: onRetry
            )
            .padding(.top, .space4)
        }
    }
}

@available(iOS 26, *)
#Preview {
    FailureMessageView(
        title: Strings.Launch.networkErrorTitle,
        message: Strings.Launch.networkErrorMessage,
        onRetry: {}
    )
}
