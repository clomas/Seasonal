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

    let onSelect: (StateLocation) -> Void
    let onFindLocationAgain: () -> Void

    var body: some View {
        VStack(spacing: .space2) {
            Text(Strings.Launch.chooseLocation)
                .font(.sectionTitle)
                .padding(.bottom, .space4)

            ForEach(StateLocation.selectable, id: \.self) { state in
                TintedGlassCapsuleButton(label: state.fullName.capitalized, systemImage: Symbol.location) {
                    onSelect(state)
                }
            }

            Button(action: onFindLocationAgain) {
                Label(Strings.Launch.findLocationAgain, systemImage: Symbol.findLocation)
                    .font(.label)
                    .foregroundStyle(Colour.accent)
            }
            .buttonStyle(.plain)
            .padding(.top, .space6)
        }
        .padding(.horizontal, .space6)
    }
}

@available(iOS 26, *)
#Preview {
    LocationPickerView(onSelect: { _ in }, onFindLocationAgain: {})
}
