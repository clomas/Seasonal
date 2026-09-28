//
//  PeriodJumpPicker.swift
//  Seasonal
//
//  Created by Clint Thomas on 9/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

/// Sets `jumpToIndex`, which the pager scrolls to and then clears.
@available(iOS 26.0, *)
struct PeriodJumpPicker<Period: PeriodType>: View {

    @Binding var jumpToIndex: Int?

    let title: String
    let currentIndex: Int

    var body: some View {
        Picker(title, selection: selection) {
            ForEach(Array(Period.allCases.enumerated()), id: \.offset) { index, period in
                Text(period.title).tag(index)
            }
        }
    }

    private var selection: Binding<Int> {
        Binding(get: { currentIndex }, set: { jumpToIndex = $0 })
    }
}

@available(iOS 26.0, *)
#Preview {
    Menu(Strings.Tab.months) {
        PeriodJumpPicker<Months>(jumpToIndex: .constant(nil), title: Strings.Jump.toMonth, currentIndex: 0)
    }
}
