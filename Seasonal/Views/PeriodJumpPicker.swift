//
//  PeriodJumpPicker.swift
//  Seasonal
//
//  Created by Clint Thomas on 9/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

/// Picks a period (month or season) for the pager to jump to — the content of the navigation
/// title's menu. The current period is ticked; picking one sets `jumpToIndex`, which the pager
/// scrolls to and clears.
@available(iOS 26.0, *)
struct PeriodJumpPicker<Period: PeriodType>: View {

    let title: String
    /// Index into `Period.allCases` the pager is showing.
    let current: Int
    @Binding var jumpToIndex: Int?

    var body: some View {
        Picker(title, selection: selection) {
            ForEach(Array(Period.allCases.enumerated()), id: \.offset) { index, period in
                Text(period.title).tag(index)
            }
        }
    }

    private var selection: Binding<Int> {
        Binding(get: { current }, set: { jumpToIndex = $0 })
    }
}

@available(iOS 26.0, *)
#Preview {
    Menu("Months") {
        PeriodJumpPicker<Months>(title: "Jump to a month", current: 0, jumpToIndex: .constant(nil))
    }
}
