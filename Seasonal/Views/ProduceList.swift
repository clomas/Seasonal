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

    @State var parentTab: MainTabScreen.Tabs
    @Binding var selectedCategory: ProduceCategory
    
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
        searchText: String = ""
    ) {
        self.produce = produce
        self.selectedPeriodName = selectedPeriodName
        self.parentTab = parentTab
        self._selectedCategory = selectedCategory
        self.searchText = searchText
    }

    let selectedPeriodName: String

    var body: some View {
        ZStack {
            Colour.background.ignoresSafeArea()

            if filteredProduce.isEmpty {
                emptyProduceListView
                    .padding(.bottom, .largePadding)
            } else {
                List(filteredProduce, id: \.id) { item in
                    ProduceListRow(produce: .constant(item))
                        .listRowSeparator(.hidden)
                        .listRowInsets(.topListRowInset)
                        .listRowBackground(Color.clear)
                }
                .accessibilityIdentifier("produceList")
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: .largePadding)
                }
            }
        }
    }

    private var emptyProduceListView: some View {
        VStack(spacing: 6) {
            Image.settings
                .resizable()
                .frame(width: 50, height: 50)
                .padding(20)
            Text(parentTab.emptyProduceListViewMessage ?? String.nothingToSeeHereMessage(tryAnother: selectedPeriodName.lowercased()))
        }
    }
}
