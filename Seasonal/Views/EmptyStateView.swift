//
//  EmptyStateView.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

struct EmptyStateView: View {

    let icon: Image
    let message: String

    var body: some View {
        VStack(spacing: .space2) {
            icon
                .font(.largeTitle)
                .padding(.bottom, .space5)
            Text(message)
                .font(.bodyText)
        }
        .foregroundStyle(.secondary)
    }
}

#Preview {
    EmptyStateView(icon: .nothingToShow, message: Strings.EmptyState.period)
}
