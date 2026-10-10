//
//  LocationPickerView.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct LocationPickerView: View {

    let isFindingLocation: Bool
    let onSelect: (StateLocation) -> Void
    let onFindLocationAgain: () -> Void

    var body: some View {
        VStack(spacing: .space2) {
            Text(Strings.Launch.chooseLocation)
                .font(.sectionTitle)
                .padding(.bottom, .space4)
                .accessibilityAddTraits(.isHeader)

            ForEach(StateLocation.selectable, id: \.self) { state in
                TintedGlassCapsuleButton(label: state.fullName, systemImage: Symbol.location) {
                    onSelect(state)
                }
            }

            Button(action: onFindLocationAgain) {
                // Hidden rather than swapped out, so the button keeps its size while the spinner shows.
                Label(Strings.Launch.findLocationAgain, systemImage: Symbol.findLocation)
                    .opacity(isFindingLocation ? 0 : 1)
                    .overlay {
                        if isFindingLocation {
                            ProgressView()
                        }
                    }
            }
            .font(.buttonLabel)
            .buttonStyle(.glass)
            .disabled(isFindingLocation)
            .accessibilityValue(isFindingLocation ? Strings.Launch.loading : "")
                .controlSize(.large)
                .tint(Colour.accent)
                .padding(.top, .space6)
        }
        .padding(.horizontal, .space6)
    }
}

@available(iOS 26, *)
#Preview {
    LocationPickerView(isFindingLocation: false, onSelect: { _ in }, onFindLocationAgain: {})
}
