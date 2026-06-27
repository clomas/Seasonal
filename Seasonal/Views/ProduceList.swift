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

    let parentTab: MainTabScreen.Tabs
    @Binding var selectedCategory: ProduceCategory
    /// Drives the top overlay buttons: hidden while scrolling down, shown while
    /// scrolling up or near the top.
    @Binding var chromeVisible: Bool

    let produce: [Produce]

    var searchText: String = ""

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

    init(
        produce: [Produce],
        selectedPeriodName: String,
        parentTab: MainTabScreen.Tabs,
        selectedCategory: Binding<ProduceCategory>,
        searchText: String = "",
        chromeVisible: Binding<Bool> = .constant(true)
    ) {
        self.produce = produce
        self.selectedPeriodName = selectedPeriodName
        self.parentTab = parentTab
        self._selectedCategory = selectedCategory
        self.searchText = searchText
        self._chromeVisible = chromeVisible
    }

    let selectedPeriodName: String

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

        guard shouldShow != chromeVisible else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            chromeVisible = shouldShow
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
