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
    /// Set to a period index to programmatically scroll to it; reset to nil once handled.
    @Binding var jumpToIndex: Int?
    /// Reports the period index currently centred in the pager, so callers (e.g. the jump
    /// menu) can reflect what the user is looking at.
    @Binding var currentIndex: Int
    var onPeekFinished: (() async -> Void)? = nil
    @ViewBuilder let cell: (PeriodItem) -> Cell

    private let buffer: [BufferSlot]
    private let startSlot: Int
    private let count: Int
    private let centerOffset: Int

    @State private var scrollPosition: ScrollPosition
    @State private var hasPeeked: Bool = false

    init(
        periods: [PeriodItem],
        initialIndex: Int,
        jumpToIndex: Binding<Int?> = .constant(nil),
        currentIndex: Binding<Int> = .constant(0),
        onPeekFinished: (() async -> Void)? = nil,
        @ViewBuilder cell: @escaping (PeriodItem) -> Cell
    ) {
        self.periods = periods
        self.initialIndex = initialIndex
        self._jumpToIndex = jumpToIndex
        self._currentIndex = currentIndex
        self.onPeekFinished = onPeekFinished
        self.cell = cell

        let count = max(periods.count, 1)
        let repeats = 21
        let centerOffset = (repeats / 2) * count
        let startSlot = centerOffset + initialIndex
        self.startSlot = startSlot
        self.count = count
        self.centerOffset = centerOffset

        var slots: [BufferSlot] = []
        slots.reserveCapacity(repeats * count)
        for slot in 0..<(repeats * count) {
            let periodIndex = ((slot - centerOffset) % count + count) % count
            slots.append(BufferSlot(id: slot, period: periods[periodIndex]))
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
            guard !hasPeeked, GlobalSettings.swipeTipShown.swipe else { return }
            hasPeeked = true
            Task {
                await runPeekSequence()
            }
        }
        .onChange(of: jumpToIndex) { _, newValue in
            guard let index = newValue else { return }
            jump(to: index)
            jumpToIndex = nil
        }
        .onChange(of: scrollPosition) {
            guard let slot = scrollPosition.viewID(type: Int.self) else { return }
            currentIndex = periodIndex(for: slot)
        }
        // Another pager sharing `currentIndex` moved (the months tab and the search tab each
        // hold one), so follow it without animating — this one is off screen.
        .onChange(of: currentIndex) { _, newIndex in
            let current = scrollPosition.viewID(type: Int.self) ?? startSlot
            guard periodIndex(for: current) != newIndex else { return }
            scrollPosition.scrollTo(id: nearestSlot(for: newIndex))
        }
    }

    private func periodIndex(for slot: Int) -> Int {
        ((slot - centerOffset) % count + count) % count
    }

    /// The buffer slot showing `index` that's nearest the current position, so a scroll to
    /// it covers the shortest distance.
    private func nearestSlot(for index: Int) -> Int {
        let current = scrollPosition.viewID(type: Int.self) ?? startSlot
        let nearestRepeat = (Double(current - centerOffset - index) / Double(count)).rounded()
        return centerOffset + index + Int(nearestRepeat) * count
    }

    private func jump(to index: Int) {
        withAnimation(.easeInOut(duration: 0.4)) {
            scrollPosition.scrollTo(id: nearestSlot(for: index))
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
