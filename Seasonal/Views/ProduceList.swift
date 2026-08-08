//
//  ProduceList.swift
//  Seasonal
//
//  Created by Clint Thomas on 27/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct ProduceList: View {

    /// The filter inputs stay plain arguments rather than being read from `MainScreenState`,
    /// so `filteredProduce` is a pure function of what's passed in and can be unit tested
    /// without a rendered view hierarchy.
    let produce: [Produce]
    let parentTab: MainTabScreen.Tabs
    var selectedCategory: ProduceCategory = .all
    var searchText: String = ""

    /// Only the ambient chrome comes from the environment: scrolling this list is what hides
    /// and reveals the top buttons, and a tap in it drops the search keyboard.
    @Environment(MainScreenState.self) private var state

    var filteredProduce: [Produce] {
        let categoryFiltered: [Produce] = {
            guard selectedCategory != .all else { return produce }
            return produce.filter { $0.category == selectedCategory }
        }()

        guard !searchText.isEmpty else { return categoryFiltered }

        return categoryFiltered.filter {
            $0.name?.localizedCaseInsensitiveContains(searchText) == true
        }
    }

    var body: some View {
        ZStack {
            Colour.background.ignoresSafeArea()

            if filteredProduce.isEmpty {
                emptyProduceListView
                    .padding(.bottom, .largePadding)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredProduce, id: \.id) { item in
                            ProduceListRow(produce: .constant(item), showMonths: !parentTab.isSeasons)
                                .padding(.topListRowInset)
                                .transition(.slide.combined(with: .opacity))
                        }
                    }
                    .padding(.bottom, .largePadding)
                }
                .accessibilityIdentifier("produceList")
                .scrollIndicators(.hidden)
                // Replaces the old hand-rolled tap-to-dismiss gesture: the system drops the
                // search keyboard as soon as the list is dragged.
                .scrollDismissesKeyboard(.immediately)
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    geometry.contentOffset.y
                } action: { oldOffset, newOffset in
                    updateChromeVisibility(from: oldOffset, to: newOffset)
                }
            }
        }
    }

    /// Hides the top chrome when scrolling down, reveals it when scrolling up or
    /// near the top. A small threshold avoids flicker from tiny offset changes.
    private func updateChromeVisibility(from oldOffset: CGFloat, to newOffset: CGFloat) {
        let threshold: CGFloat = 8
        let shouldShow: Bool
        
        if newOffset < 60 {
            shouldShow = true
        } else if newOffset > oldOffset + threshold {
            shouldShow = false
        } else if newOffset < oldOffset - threshold {
            shouldShow = true
        } else {
            return
        }

        guard shouldShow != state.chromeVisible else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            state.chromeVisible = shouldShow
        }
    }

    private var emptyProduceListView: some View {
        VStack(spacing: .space2) {
            parentTab.emptyListIcon
                .font(.largeTitle)
                .foregroundStyle(.secondary)
                .padding(.bottom, .space5)
            Text(searchText.isEmpty == true ? parentTab.emptyProduceListViewMessage : "No search results")
                .font(.bodyText)
                .foregroundStyle(.secondary)
        }
    }
}
