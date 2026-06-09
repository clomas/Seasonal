//
//  MainTabScreen.swift
//  Seasonal
//
//  Created by Clint Thomas on 30/6/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI
import TipKit

@available(iOS 26, *)
struct MainTabScreen: View {

    enum Tabs: Hashable {
        case favourites
        case months(Months)
        case seasons(Seasons)
        case search

        var title: String {
            return switch self {
            case .favourites:
                "Favourites"
            case .months(let month):
                month.title
            case .seasons(let season):
                season.title
            case .search:
                "Search"
            }
        }

        var emptyProduceListViewMessage: String? {
            return if case .favourites = self {
                "❤️ Favourite some produce to see it in here."
            } else {
                nil
            }
        }
    }

    @EnvironmentObject var appCoordinator: AppCoordinator

    @State private var selectedTab: Tabs = StoredSelectedTab.tab
    @State private var selectedCategory: ProduceCategory = .all
    @State private var searchQuery: String = ""
    @State private var showTip: Bool = false

    private var tip: SwipeOnboardingTip {
        switch selectedTab {
        case .months:
            SwipeOnboardingTip(context: "months")
        case .seasons:
            SwipeOnboardingTip(context: "seasons")
        default:
            SwipeOnboardingTip(context: "default")
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Favourites", systemImage: "heart", value: .favourites) {
                produceListNavigationView(title: Tabs.favourites.title)
            }

            Tab("Months", systemImage: "calendar", value: .months(Months.currentPeriod)) {
                PeriodPagerView<Months>(
                    periods: Months.allCases,
                    selectedTab: .months(Months.currentPeriod),
                    searchQuery: "",
                    isSearching: false,
                    selectedCategory: $selectedCategory,
                    onPeekFinished: { peekFinished() }
                )
            }

            Tab("Seasons", systemImage: "cloud.sun", value: .seasons(Seasons.currentPeriod)) {
                PeriodPagerView<Seasons>(
                    periods: Seasons.allCases,
                    selectedTab: .seasons(Seasons.currentPeriod),
                    searchQuery: "",
                    isSearching: false,
                    selectedCategory: $selectedCategory,
                    onPeekFinished: { peekFinished() }
                )
            }

            Tab(value: .search, role: .search) {
                searchTab
            }
        }
        .tint(Colour.inSeason)
        .onChange(of: selectedTab) { _, newTab in
            StoredSelectedTab.storeTab(newTab)
        }
        .overlay {
            if showTip {
                TipViewBlockingOverlay(showTip: $showTip, tip: tip)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            FloatingCategoryButton(selectedCategory: $selectedCategory)
                .padding(.trailing, 18)
                .padding(.bottom, 60)
        }
        .overlay(alignment: .topTrailing) {
//            if case .months = selectedTab {
//                FloatingMonthsButton(action: {})
//                    .padding(.trailing, 18)
//                    .padding(.top, 60)
//            }
        }
    }

    // MARK: - Private

    @ViewBuilder
    private var searchTab: some View {
        NavigationStack {
            ProduceList(
                produce: appCoordinator.produceStore.allProduce,
                selectedPeriodName: "produce",
                parentTab: .search,
                selectedCategory: $selectedCategory,
                searchText: searchQuery
            )
        }
        .searchable(text: $searchQuery, prompt: "Search produce")
    }

    @ViewBuilder
    private func produceListNavigationView(title: String) -> some View {
        ProduceListNavigationView(title: title) {
            ProduceList(
                produce: appCoordinator.produceStore.favourites,
                selectedPeriodName: "favourites",
                parentTab: selectedTab,
                selectedCategory: $selectedCategory
            )
        }
    }

    private func peekFinished() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            withAnimation(.easeInOut(duration: 1.5)) {
                showTip = false
            }
        }
    }
}

@available(iOS 26, *)
#Preview {
    MainTabScreen()
        .environmentObject(previewCoordinator)
}
