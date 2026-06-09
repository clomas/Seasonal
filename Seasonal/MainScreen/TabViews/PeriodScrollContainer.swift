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

    let periods: [PeriodItem]
    let initialIndex: Int
    var onPeekFinished: (() async -> Void)? = nil
    @ViewBuilder let cell: (PeriodItem) -> Cell

    @State private var selectedIndex: Int?
    @State private var isPeeking: Bool = false
    @State private var peekTask: Task<Void, Never>?

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(periods) { period in
                    cell(period)
                }
            }
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

    private func performIntroAnimation() {
        selectedIndex = initialIndex
        isPeeking = true
        peekTask?.cancel()

        let count = periods.count
        let base = initialIndex

        func clamp(_ i: Int) -> Int { min(max(i, 0), count - 1) }

        peekTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)
            withAnimation(.easeInOut(duration: 1.6)) { selectedIndex = clamp(base - 1) }

            try? await Task.sleep(nanoseconds: 2_500_000_000)
            withAnimation(.easeInOut(duration: 1.2)) { selectedIndex = clamp(base + 1) }

            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation(.easeInOut(duration: 1)) { selectedIndex = base }

            isPeeking = false
            await onPeekFinished?()
        }
    }
}
