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

    @EnvironmentObject var produceStore: ProduceStore

    @State private var state = MainScreenState()
    @State private var showTip = !GlobalSettings.swipeTipShown.swipe
    @State private var showInfo = false
    @State private var jumpMonthIndex: Int?
    @State private var jumpSeasonIndex: Int?
    @State private var currentMonthIndex = Months.currentPeriod.index
    @State private var currentSeasonIndex = Seasons.currentPeriod.index

    private let tipDismissDelay: Duration = .milliseconds(500)
    private let tipFadeDuration: TimeInterval = 1.5

    var body: some View {
        TabView(selection: $state.selectedTab) {
            Tab(Strings.Tab.favourites, systemImage: Symbol.favourites, value: .favourites) {
                tabScreen(for: .favourites)
            }
            Tab(Strings.Tab.months, systemImage: Symbol.months, value: .months(Months.currentPeriod)) {
                tabScreen(for: .months(Months.currentPeriod))
            }
            Tab(Strings.Tab.seasons, systemImage: Symbol.seasons, value: .seasons(Seasons.currentPeriod)) {
                tabScreen(for: .seasons(Seasons.currentPeriod))
            }
            Tab(Strings.Tab.search, systemImage: Symbol.search, value: Tabs.search, role: .search) {
                tabScreen(for: state.searchOrigin, searchText: state.searchQuery)
            }
        }
        .accessibilityIdentifier("mainTabView")
        .tabViewSearchActivation(.searchTabSelection)
        .tint(Colour.inSeason)
        .onChange(of: state.selectedTab) { _, newTab in
            StoredSelectedTab.storeTab(newTab)
        }
        .sheet(isPresented: $showInfo) {
            InfoScreen()
        }
        .overlay {
            if let tip, showTip {
                TipViewBlockingOverlay(showTip: $showTip, tip: tip)
            }
        }
        .environment(state)
    }

    private var tip: SwipeOnboardingTip? {
        switch state.selectedTab {
        case .months: SwipeOnboardingTip(context: Strings.Onboarding.monthsContext)
        case .seasons: SwipeOnboardingTip(context: Strings.Onboarding.seasonsContext)
        case .favourites, .search: nil
        }
    }

    /// Only set while the swipe tip hasn't been shown, so the pager peeks just once.
    private var peekFinishedHandler: (() async -> Void)? {
        guard showTip else { return nil }
        return { await dismissTipAfterPeek() }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            CategoryFilterButton(selectedCategory: $state.selectedCategory)
        }
        ToolbarItem(placement: .topBarTrailing) {
            InfoButton { showInfo = true }
        }
    }

    /// One stack per tab, never per pager page: a stack per page would each claim the search
    /// field. The title stays inline because a collapsing title would track the horizontal pager.
    private func tabScreen(for tab: Tabs, searchText: String? = nil) -> some View {
        NavigationStack {
            browsingScreen(for: tab, searchText: searchText ?? "")
                .navigationTitle(title(for: tab))
                .toolbarTitleDisplayMode(.inline)
                .toolbarTitleMenuIfPresent(titleMenu(for: tab))
                .toolbar { toolbar }
                .searchableIfPresent(text: searchText == nil ? nil : $state.searchQuery, prompt: Strings.Search.prompt)
                .searchPresentationToolbarBehavior(.avoidHidingContent)
        }
    }

    private func title(for tab: Tabs) -> String {
        switch tab {
        case .months: Months.allCases[currentMonthIndex].title
        case .seasons: Seasons.allCases[currentSeasonIndex].title
        case .favourites, .search: Tabs.favourites.title
        }
    }

    private func titleMenu(for tab: Tabs) -> AnyView? {
        switch tab {
        case .months:
            AnyView(PeriodJumpPicker<Months>(jumpToIndex: $jumpMonthIndex, title: Strings.Jump.toMonth, currentIndex: currentMonthIndex))
        case .seasons:
            AnyView(PeriodJumpPicker<Seasons>(jumpToIndex: $jumpSeasonIndex, title: Strings.Jump.toSeason, currentIndex: currentSeasonIndex))
        case .favourites, .search:
            nil
        }
    }

    /// The search tab builds a second copy of the screen it was opened from; the pagers share
    /// index bindings so both copies stay on the same period.
    @ViewBuilder
    private func browsingScreen(for tab: Tabs, searchText: String) -> some View {
        switch tab {
        case .favourites, .search:
            ProduceList(
                produce: produceStore.favourites,
                parentTab: .favourites,
                selectedCategory: state.selectedCategory,
                searchText: searchText
            )
        case .months:
            PeriodPagerView<Months>(
                jumpToIndex: $jumpMonthIndex,
                currentIndex: $currentMonthIndex,
                searchText: searchText,
                onPeekFinished: peekFinishedHandler
            )
        case .seasons:
            PeriodPagerView<Seasons>(
                jumpToIndex: $jumpSeasonIndex,
                currentIndex: $currentSeasonIndex,
                searchText: searchText,
                onPeekFinished: peekFinishedHandler
            )
        }
    }

    private func dismissTipAfterPeek() async {
        try? await Task.sleep(for: tipDismissDelay)
        withAnimation(.easeInOut(duration: tipFadeDuration)) {
            showTip = false
        }
        GlobalSettings.swipeTipShown = TipShown(swipe: true)
    }
}

@available(iOS 26, *)
#Preview {
    MainTabScreen()
        .environmentObject(previewCoordinator)
        .environmentObject(previewCoordinator.produceStore)
}
