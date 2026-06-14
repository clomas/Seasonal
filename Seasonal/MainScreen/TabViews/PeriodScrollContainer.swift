//
//  PeriodScrollContainer.swift
//  Seasonal
//
//  Created by Clint Thomas on 1/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

struct PeriodItem: Identifiable {
    let id: Int
    let title: String
}

@available(iOS 26, *)
struct PeriodScrollContainer<Cell: View>: View {

    private struct BufferSlot: Identifiable {
        let id: Int
        let period: PeriodItem
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let periods: [PeriodItem]
    let initialIndex: Int
    var onPeekFinished: (() async -> Void)? = nil
    @ViewBuilder let cell: (PeriodItem) -> Cell

    private let buffer: [BufferSlot]
    private let startSlot: Int

    @State private var scrollPosition: ScrollPosition
    @State private var hasPeeked: Bool = false

    init(
        periods: [PeriodItem],
        initialIndex: Int,
        onPeekFinished: (() async -> Void)? = nil,
        @ViewBuilder cell: @escaping (PeriodItem) -> Cell
    ) {
        self.periods = periods
        self.initialIndex = initialIndex
        self.onPeekFinished = onPeekFinished
        self.cell = cell

        let count = max(periods.count, 1)
        let repeats = 21
        let centerOffset = (repeats / 2) * count
        let startSlot = centerOffset + initialIndex
        self.startSlot = startSlot

        var slots: [BufferSlot] = []
        slots.reserveCapacity(repeats * count)
        for slot in 0..<(repeats * count) {
            let periodIdx = ((slot - centerOffset) % count + count) % count
            slots.append(BufferSlot(id: slot, period: periods[periodIdx]))
        }
        self.buffer = slots

        self._scrollPosition = State(initialValue: ScrollPosition(id: startSlot))
    }

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(buffer) { slot in
                    cell(slot.period)
                        .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition($scrollPosition)
        .onAppear {
            guard !hasPeeked else { return }
//            guard !hasPeeked, GlobalSettings.swipeTipShown.swipe else { return }
            hasPeeked = true
            Task {
                await runPeekSequence()
            }
        }
    }

    private func runPeekSequence() async {
        try? await Task.sleep(for: .seconds(0.5))

        await hop(to: startSlot + 1)
        await hop(to: startSlot)

        await hop(to: startSlot - 1)
        await hop(to: startSlot)

        await onPeekFinished?()
    }

    /// Animates a single-cell scroll and waits long enough for the scroll view to
    /// land and `LazyHStack` to settle before the next hop begins.
    private func hop(to id: Int) async {
        withAnimation(.easeInOut(duration: 1)) {
            scrollPosition.scrollTo(id: id)
        }
        try? await Task.sleep(for: .seconds(1))
    }
}
