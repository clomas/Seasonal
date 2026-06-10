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

    let periods: [PeriodItem]
    let initialIndex: Int
    var onPeekFinished: (() async -> Void)? = nil
    @ViewBuilder let cell: (PeriodItem) -> Cell

    private let buffer: [BufferSlot]
    private let startSlot: Int

    @State private var selectedIndex: Int?
    @State private var isPeeking: Bool = false
    @State private var peekTask: Task<Void, Never>?
    @State private var introOffset: CGFloat = 0

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

        self._selectedIndex = State(initialValue: startSlot)
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(buffer) { slot in
                        cell(slot.period)
                            .containerRelativeFrame(.horizontal)
                    }
                }
                .offset(x: introOffset)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $selectedIndex)
            .disabled(isPeeking)
            .onAppear {
                performIntroAnimation()
            }
            .onDisappear {
                peekTask?.cancel()
                isPeeking = false
            }
        }
    }

    private func performIntroAnimation() {
        isPeeking = true
        peekTask?.cancel()

        peekTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 150_000_000)

            withAnimation(.easeInOut(duration: 1.2)) {
                introOffset = -150
            }

            try? await Task.sleep(nanoseconds: 1_500_000_000)

            withAnimation(.easeInOut(duration: 1.0)) {
                introOffset = 150
            }

            try? await Task.sleep(nanoseconds: 1_300_000_000)

            withAnimation(.easeInOut(duration: 0.8)) {
                introOffset = 0
            }

            isPeeking = false
            await onPeekFinished?()
        }
    }
}
