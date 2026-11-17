//
//  ProduceListSectionHeader.swift
//  Seasonal
//
//  Created by Clint Thomas on 13/11/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct ProduceListSectionHeader: View {

    let title: String

    var body: some View {
        Text(title)
            .font(.sectionTitle)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, .space4)
            .padding(.top, .space4)
            .padding(.bottom, .space1)
            .accessibilityAddTraits(.isHeader)
    }
}

#if DEBUG
@available(iOS 26, *)
#Preview {
    ProduceListSectionHeader(title: Strings.PinnedSection.favourites)
}
#endif
