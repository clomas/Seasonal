//
//  PeriodScrollContainer.swift
//  Seasonal
//
//  Created by Clint Thomas on 1/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

/// A horizontally paging, effectively infinite carousel of periods: the periods repeat in a
/// buffer and scrolling starts from its middle.
@available(iOS 26, *)
struct PeriodScrollContainer<Cell: View>: View {

    private struct BufferSlot: Identifiable {
        let id: Int
        let period: PeriodItem
    }

    @Binding var jumpToIndex: Int?
    @Binding var currentIndex: Int

    let periods: [PeriodItem]
    let initialIndex: Int
    /// The onboarding peek runs only when this is set.
    let onPeekFinished: (() async -> Void)?
    @ViewBuilder let cell: (PeriodItem) -> Cell

    private static var bufferRepeats: Int { 21 }
    private static var jumpDuration: TimeInterval { 0.4 }
    private static var peekStartDelay: Duration { .milliseconds(500) }
    private static var peekHopDuration: TimeInterval { 1 }

    private let buffer: [BufferSlot]
    private let startSlot: Int
    private let count: Int
    private let centerOffset: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var scrollPosition: ScrollPosition
    @State private var hasPeeked = false

    init(
        periods: [PeriodItem],
        initialIndex: Int,
        jumpToIndex: Binding<Int?> = .constant(nil),
        currentIndex: Binding<Int> = .constant(0),
        onPeekFinished: (() async -> Void)? = nil,
        @ViewBuilder cell: @escaping (PeriodItem) -> Cell
    ) {
        let count = max(periods.count, 1)
        let centerOffset = (Self.bufferRepeats / 2) * count
        let startSlot = centerOffset + initialIndex

        self.periods = periods
        self.initialIndex = initialIndex
        self._jumpToIndex = jumpToIndex
        self._currentIndex = currentIndex
        self.onPeekFinished = onPeekFinished
        self.cell = cell
        self.count = count
        self.centerOffset = centerOffset
        self.startSlot = startSlot
        self.buffer = (0..<(Self.bufferRepeats * count)).map { slot in
            BufferSlot(id: slot, period: periods[((slot - centerOffset) % count + count) % count])
        }
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
            guard !hasPeeked, onPeekFinished != nil else { return }
            hasPeeked = true
            Task { await runPeekSequence() }
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
        // Another pager sharing `currentIndex` moved; follow it without animating.
        .onChange(of: currentIndex) { _, newIndex in
            let current = scrollPosition.viewID(type: Int.self) ?? startSlot
            guard periodIndex(for: current) != newIndex else { return }
            scrollPosition.scrollTo(id: nearestSlot(for: newIndex))
        }
    }

    private func periodIndex(for slot: Int) -> Int {
        ((slot - centerOffset) % count + count) % count
    }

    private func nearestSlot(for index: Int) -> Int {
        let current = scrollPosition.viewID(type: Int.self) ?? startSlot
        let nearestRepeat = (Double(current - centerOffset - index) / Double(count)).rounded()
        return centerOffset + index + Int(nearestRepeat) * count
    }

    private func jump(to index: Int) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: Self.jumpDuration)) {
            scrollPosition.scrollTo(id: nearestSlot(for: index))
        }
    }

    private func runPeekSequence() async {
        try? await Task.sleep(for: Self.peekStartDelay)
        let hops = [startSlot + 1, startSlot, startSlot - 1, startSlot]
        if reduceMotion {
            // Keep the tip on screen as long as the peek would have, without the motion.
            try? await Task.sleep(for: .seconds(Self.peekHopDuration * Double(hops.count)))
        } else {
            for slot in hops {
                await hop(to: slot)
            }
        }
        await onPeekFinished?()
    }

    private func hop(to id: Int) async {
        withAnimation(.easeInOut(duration: Self.peekHopDuration)) {
            scrollPosition.scrollTo(id: id)
        }
        try? await Task.sleep(for: .seconds(Self.peekHopDuration))
    }
}
