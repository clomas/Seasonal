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

        var isSeasons: Bool {
            if case .seasons = self { true } else { false }
        }
    }

    @EnvironmentObject var produceStore: ProduceStore

    /// Chrome shared with the tab bar and the produce lists — see `MainScreenState`. Everything
    /// below it is state only this screen reads.
    @State private var state = MainScreenState()

    @State private var showTip: Bool = GlobalSettings.swipeTipShown.swipe
    @State private var showInfo: Bool = false
    @State private var jumpMonthIndex: Int? = nil
    @State private var jumpSeasonIndex: Int? = nil
    @State private var currentMonthIndex: Int = Months.currentPeriod.index
    @State private var currentSeasonIndex: Int = Seasons.currentPeriod.index

    private var tip: SwipeOnboardingTip? {
        switch state.selectedTab {
        case .months:
            SwipeOnboardingTip(context: "months")
        case .seasons:
            SwipeOnboardingTip(context: "seasons")
        default:
            nil
        }
    }

    var body: some View {
        TabView(selection: $state.selectedTab) {
            Tab("Favourites", systemImage: "heart", value: .favourites) {
                tabScreen(for: .favourites)
            }

            Tab("Months", systemImage: "calendar", value: .months(Months.currentPeriod)) {
                tabScreen(for: .months(Months.currentPeriod))
            }

            Tab("Seasons", systemImage: "cloud.sun", value: .seasons(Seasons.currentPeriod)) {
                tabScreen(for: .seasons(Seasons.currentPeriod))
            }

            // The search role is what anchors the field to the bottom bar and floats it above
            // the keyboard. Its content is the screen search was opened from, filtered, so the
            // month or season, its title and its toolbar all stay put while searching.
            Tab("Search", systemImage: "magnifyingglass", value: Tabs.search, role: .search) {
                tabScreen(for: state.searchOrigin, searchText: state.searchQuery)
            }
        }
        .accessibilityIdentifier("mainTabView")
        // Selecting the search tab focuses the field straight away. Without this the field is
        // presented but idle, so reaching the keyboard costs a second tap on it.
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

    // MARK: - Private

    /// One navigation stack per tab, around the whole screen — never one per pager page, which
    /// would each claim the search field and fight over the title. The title is inline because a
    /// collapsing large title tracks a scroll view, and the one a stack finds here is the
    /// horizontal pager rather than the lists.
    /// `searchText` is non-nil only on the search tab.
    private func tabScreen(for tab: Tabs, searchText: String? = nil) -> some View {
        NavigationStack {
            browsingScreen(for: tab, searchText: searchText ?? "")
                .navigationTitle(title(for: tab))
                .toolbarTitleDisplayMode(.inline)
                .modifier(TitleMenuIf(menu: titleMenu(for: tab)))
                .toolbar { toolbar }
                .modifier(SearchableIf(text: searchText == nil ? nil : $state.searchQuery))
        }
    }

    /// Tapping a period title jumps its pager. Favourites gets none — even an empty title menu
    /// still draws the chevron.
    private func titleMenu(for tab: Tabs) -> AnyView? {
        switch tab {
        case .months:
            AnyView(PeriodJumpPicker<Months>(title: "Jump to a month", current: currentMonthIndex, jumpToIndex: $jumpMonthIndex))
        case .seasons:
            AnyView(PeriodJumpPicker<Seasons>(title: "Jump to a season", current: currentSeasonIndex, jumpToIndex: $jumpSeasonIndex))
        case .favourites, .search:
            nil
        }
    }

    /// One control either side of the centred title.
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            CategoryFilterButton(selectedCategory: $state.selectedCategory)
        }
        ToolbarItem(placement: .topBarTrailing) {
            InfoButton { showInfo = true }
        }
    }

    /// The period the tab's pager is showing, so the title follows swipes and jumps.
    private func title(for tab: Tabs) -> String {
        switch tab {
        case .months: Months.allCases[currentMonthIndex].title
        case .seasons: Seasons.allCases[currentSeasonIndex].title
        case .favourites, .search: Tabs.favourites.title
        }
    }

    /// The screen for a browsing tab. The search tab builds a second copy of the one it was
    /// opened from, passing its query; the pagers share their index bindings, so both copies
    /// stay on one period.
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
                periods: Months.allCases,
                jumpToIndex: $jumpMonthIndex,
                currentIndex: $currentMonthIndex,
                searchText: searchText,
                onPeekFinished: { peekFinished() }
            )
        case .seasons:
            PeriodPagerView<Seasons>(
                periods: Seasons.allCases,
                jumpToIndex: $jumpSeasonIndex,
                currentIndex: $currentSeasonIndex,
                searchText: searchText,
                onPeekFinished: { peekFinished() }
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

/// `.toolbarTitleMenu` only when there's a menu, so every tab can share `tabScreen(for:)`.
@available(iOS 26, *)
private struct TitleMenuIf: ViewModifier {
    let menu: AnyView?

    func body(content: Content) -> some View {
        if let menu {
            content.toolbarTitleMenu { menu }
        } else {
            content
        }
    }
}

/// `.searchable` only when given a binding, so every tab can share `tabScreen(for:)`.
@available(iOS 26, *)
private struct SearchableIf: ViewModifier {
    let text: Binding<String>?

    func body(content: Content) -> some View {
        if let text {
            content
                .searchable(text: text, prompt: "Search produce")
                // By default the system hides the navigation bar while searching, which takes
                // the period title and toolbar with it.
                .searchPresentationToolbarBehavior(.avoidHidingContent)
        } else {
            content
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
        case .search:
            "Search"
        }
    }
    
    var emptyListIcon: Image {
        return switch self {
        case .favourites: .heart
        case .search: .magnifyingGlass
        case .months, .seasons: .xMarkCircle
        }
    }

    var emptyProduceListViewMessage: String {
        return switch self {
        case .favourites:
            "No favourites selected"
        case .search, .months, .seasons:
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
