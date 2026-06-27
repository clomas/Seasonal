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
        
        var isSeasons: Bool {
            if case .seasons = self { true } else { false }
        }
    }

    @EnvironmentObject var produceStore: ProduceStore

    @State private var selectedTab: Tabs = StoredSelectedTab.tab
    @State private var selectedCategory: ProduceCategory = .all
    @State private var searchQuery: String = ""
    @State private var isSearching: Bool = false
    @State private var showTip: Bool = GlobalSettings.swipeTipShown.swipe
    @State private var chromeVisible: Bool = true
    @State private var showInfo: Bool = false
    @State private var jumpMonthIndex: Int? = nil
    @State private var jumpSeasonIndex: Int? = nil
    @State private var currentMonthIndex: Int = Months.currentPeriod.index
    @State private var currentSeasonIndex: Int = Seasons.currentPeriod.index

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
                    chromeVisible: $chromeVisible,
                    jumpToIndex: $jumpMonthIndex,
                    currentIndex: $currentMonthIndex,
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
                    chromeVisible: $chromeVisible,
                    jumpToIndex: $jumpSeasonIndex,
                    currentIndex: $currentSeasonIndex,
                    onPeekFinished: { peekFinished() }
                )
                .toolbarVisibility(.hidden, for: .tabBar)
            }
        }
        .accessibilityIdentifier("mainTabView")
        .tint(Colour.inSeason)
        .onChange(of: selectedTab) { _, newTab in
            StoredSelectedTab.storeTab(newTab)
            chromeVisible = true
        }
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 12) {
                if showsPeriodPicker {
                    SelectMonthButton { periodPickerMenu }
                }
                InfoButton { showInfo = true }
            }
            .padding(.trailing, 16)
            .padding(.top, 8)
            .opacity(chromeVisible ? 1 : 0)
            .offset(y: chromeVisible ? 0 : -12)
            .animation(.easeInOut(duration: 0.25), value: chromeVisible)
        }
        .sheet(isPresented: $showInfo) {
            InfoScreen()
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

    /// The calendar "jump to period" button is only meaningful on the month/season pagers.
    private var showsPeriodPicker: Bool {
        if case .favourites = selectedTab { false } else { true }
    }

    /// Menu content for the lifted calendar button — scoped to the active tab so it jumps the
    /// matching pager via its own jump binding.
    @ViewBuilder
    private var periodPickerMenu: some View {
        switch selectedTab {
        case .seasons:
            periodMenu(Seasons.self, title: "Jump to a season", current: currentSeasonIndex, jump: $jumpSeasonIndex)
        default:
            periodMenu(Months.self, title: "Jump to a month", current: currentMonthIndex, jump: $jumpMonthIndex)
        }
    }

    /// Builds a "jump to period" section for any `PeriodType`. The button index is the period's
    /// position in `allCases`, which is what the pager's `jumpToIndex` binding expects. `current`
    /// is the index the pager is showing, so it gets a checkmark.
    @ViewBuilder
    private func periodMenu<P: PeriodType>(_ type: P.Type, title: String, current: Int, jump: Binding<Int?>) -> some View {
        Section(title) {
            ForEach(Array(P.allCases.enumerated()), id: \.offset) { index, period in
                Button {
                    jump.wrappedValue = index
                } label: {
                    if index == current {
                        Label(period.title, systemImage: "checkmark")
                    } else {
                        Text(period.title)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func produceListNavigationView(title: String) -> some View {
        ProduceListNavigationView(title: title) {
            ProduceList(
                produce: produceStore.favourites,
                selectedPeriodName: "favourites",
                parentTab: selectedTab,
                selectedCategory: $selectedCategory,
                searchText: searchQuery,
                chromeVisible: $chromeVisible
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
extension MainTabScreen.Tabs {
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
    
    var emptyListIcon: Image {
        if case .favourites = self {
            .heart
        } else {
            .xMarkCircle
        }
    }

    var emptyProduceListViewMessage: String {
        if case .favourites = self {
            "No favourites selected"
        } else {
            "Nothing to display, try something else"
        }
    }
}

@available(iOS 26, *)
#Preview {
    MainTabScreen()
        .environmentObject(previewCoordinator)
        .environmentObject(previewCoordinator.produceStore)
        .environmentObject(FeatureToggleHelper())
}
