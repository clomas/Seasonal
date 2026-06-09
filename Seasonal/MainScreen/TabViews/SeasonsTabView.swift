//
//  SeasonsTabView.swift
//  Seasonal
//
//  Created by Clint Thomas on 1/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct SeasonsTabView: View {

    @EnvironmentObject var appCoordinator: AppCoordinator

    let selectedTab: MainTabScreen.Tabs
    let searchQuery: String
    let isSearching: Bool

    @Binding var selectedCategory: ProduceCategory

    var onPeekFinished: (() async -> Void)? = nil

    private let periods: [PeriodItem] = Seasons.allCases.map {
        PeriodItem(id: $0.rawValue, title: $0.title)
    }

    var body: some View {
        PeriodScrollContainer(
            periods: periods,
            initialIndex: Seasons.currentPeriod.rawValue,
            onPeekFinished: onPeekFinished
        ) { item in
            if let season = Seasons(rawValue: item.id) {
                ProduceListNavigationView(title: cellTitle(for: season)) {
                    ProduceList(
                        produce: appCoordinator.produceStore.byPeriod(season, query: searchQuery),
                        selectedPeriodName: item.title,
                        parentTab: selectedTab,
                        selectedCategory: $selectedCategory
                    )
                    .containerRelativeFrame(.horizontal)
                }
            }
        }
    }

    private func cellTitle(for season: Seasons) -> String {
        isSearching && !searchQuery.isEmpty
            ? "\"\(searchQuery)\" in \(season.title)"
            : season.title
    }
}

@available(iOS 26, *)
#Preview {
    NavigationStack {
        SeasonsTabView(selectedTab: .seasons(.winter), searchQuery: "", isSearching: false, selectedCategory: .constant(.all))
            .environmentObject(previewCoordinator)
            .environmentObject(FeatureToggleHelper())
    }
}
