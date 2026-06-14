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

        var title: String {
            return switch self {
            case .favourites:
                "Favourites"
            case .months(let month):
                month.title
            case .seasons(let season):
                season.title
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
    @State private var isSearching: Bool = false
    @State private var showTip: Bool = true //GlobalSettings.swipeTipShown.swipe

    private var tip: SwipeOnboardingTip? {
        switch selectedTab {
        case .months:
            SwipeOnboardingTip(context: "months")
        case .seasons:
            SwipeOnboardingTip(context: "seasons")
        default:
            nil
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Favourites", systemImage: "heart", value: .favourites) {
                produceListNavigationView(title: Tabs.favourites.title)
                    .toolbarVisibility(.hidden, for: .tabBar)
            }

            Tab("Months", systemImage: "calendar", value: .months(Months.currentPeriod)) {
                PeriodPagerView<Months>(
                    periods: Months.allCases,
                    selectedTab: .months(Months.currentPeriod),
                    searchQuery: searchQuery,
                    isSearching: isSearching,
                    selectedCategory: $selectedCategory,
                    onPeekFinished: { peekFinished() }
                )
                .toolbarVisibility(.hidden, for: .tabBar)
            }

            Tab("Seasons", systemImage: "cloud.sun", value: .seasons(Seasons.currentPeriod)) {
                PeriodPagerView<Seasons>(
                    periods: Seasons.allCases,
                    selectedTab: .seasons(Seasons.currentPeriod),
                    searchQuery: searchQuery,
                    isSearching: isSearching,
                    selectedCategory: $selectedCategory,
                    onPeekFinished: { peekFinished() }
                )
                .toolbarVisibility(.hidden, for: .tabBar)
            }
        }
        .accessibilityIdentifier("mainTabView")
        .tint(Colour.inSeason)
        .onChange(of: selectedTab) { _, newTab in
            StoredSelectedTab.storeTab(newTab)
        }
        .overlay {
            if let tip, showTip {
                TipViewBlockingOverlay(showTip: $showTip, tip: tip)
            }
        }
        .overlay(alignment: .bottom) {
            MainScreenTabBar(
                selectedTab: $selectedTab,
                isSearching: $isSearching,
                searchQuery: $searchQuery,
                selectedCategory: $selectedCategory
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 6)
        }
    }

    // MARK: - Private

    @ViewBuilder
    private func produceListNavigationView(title: String) -> some View {
        ProduceListNavigationView(title: title) {
            ProduceList(
                produce: appCoordinator.produceStore.favourites,
                selectedPeriodName: "favourites",
                parentTab: selectedTab,
                selectedCategory: $selectedCategory,
                searchText: searchQuery
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
