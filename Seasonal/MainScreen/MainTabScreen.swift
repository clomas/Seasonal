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

        /// The system presents its search field when this tab is selected, so "is the search
        /// tab showing" is the same question as "is search engaged".
        var isSearch: Bool {
            if case .search = self { true } else { false }
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
                produceListNavigationView(title: Tabs.favourites.title)
            }

            Tab("Months", systemImage: "calendar", value: .months(Months.currentPeriod)) {
                PeriodPagerView<Months>(
                    periods: Months.allCases,
                    jumpToIndex: $jumpMonthIndex,
                    currentIndex: $currentMonthIndex,
                    onPeekFinished: { peekFinished() }
                )
            }

            Tab("Seasons", systemImage: "cloud.sun", value: .seasons(Seasons.currentPeriod)) {
                PeriodPagerView<Seasons>(
                    periods: Seasons.allCases,
                    jumpToIndex: $jumpSeasonIndex,
                    currentIndex: $currentSeasonIndex,
                    onPeekFinished: { peekFinished() }
                )
            }

            // The search role is what anchors the field to the bottom bar and floats it above
            // the keyboard — it only renders because the system tab bar is visible, which is
            // why the custom glass bar this replaced had to go.
            Tab("Search", systemImage: "magnifyingglass", value: Tabs.search, role: .search) {
                SearchScreen()
            }
        }
        .accessibilityIdentifier("mainTabView")
        .tint(Colour.inSeason)
        // Deliberately an overlay rather than `.tabViewBottomAccessory`: that slot draws its own
        // full-width glass tray, which read as a stray bar behind a lone button. This puts the
        // bare circle in line with the system search item instead.
        .overlay(alignment: .bottomTrailing) {
            TabBarFilterButton(selectedCategory: $state.selectedCategory, hideLabel: true)
                .padding(.trailing, 16)
                // Clears the system tab bar to sit directly above the search item, in the same
                // column and at the same size. Hand-measured: an overlay on the `TabView` is
                // laid out against the screen's safe area, not the bar's, so there's no metric
                // to read the bar's height from — worth re-checking if the bar ever changes.
                .padding(.bottom, tabBarClearance)
        }
        .onChange(of: state.selectedTab) { _, newTab in
            StoredSelectedTab.storeTab(newTab)
            state.chromeVisible = true
        }
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 12) {
                if showsPeriodPicker {
                    SelectMonthButton { dismiss in periodPickerMenu(dismiss: dismiss) }
                }
                InfoButton { showInfo = true }
            }
            .padding(.trailing, 16)
            .padding(.top, 8)
            .opacity(state.chromeVisible ? 1 : 0)
            .offset(y: state.chromeVisible ? 0 : -12)
            .animation(.easeInOut(duration: 0.25), value: state.chromeVisible)
        }
        .sheet(isPresented: $showInfo) {
            InfoScreen()
        }
        .overlay {
            if let tip, showTip {
                TipViewBlockingOverlay(showTip: $showTip, tip: tip)
            }
        }
        // Outermost so the top-right chrome overlay reads the same state as the tab content.
        .environment(state)
    }

    // MARK: - Private

    /// Vertical gap that lifts the category filter clear of the system tab bar, so it lands
    /// directly above the search item rather than on top of it. Scales with Dynamic Type
    /// alongside the button it's clearing.
    @ScaledMetric(relativeTo: .title2) private var tabBarClearance: CGFloat = 64

    /// The calendar "jump to period" button is only meaningful on the month/season pagers.
    private var showsPeriodPicker: Bool {
        switch state.selectedTab {
        case .months, .seasons: true
        case .favourites, .search: false
        }
    }

    /// Popover content for the lifted period button — scoped to the active tab so it jumps the
    /// matching pager via its own jump binding. `dismiss` closes the popover after a selection.
    @ViewBuilder
    private func periodPickerMenu(dismiss: @escaping () -> Void) -> some View {
        switch state.selectedTab {
        case .seasons:
            periodMenu(Seasons.self, title: "Jump to a season", current: currentSeasonIndex, jump: $jumpSeasonIndex, dismiss: dismiss)
        default:
            periodMenu(Months.self, title: "Jump to a month", current: currentMonthIndex, jump: $jumpMonthIndex, dismiss: dismiss)
        }
    }

    /// Builds the "jump to period" picker for any `PeriodType` as popover rows (mirroring the
    /// category filter popover). The row index is the period's position in `allCases`, which is
    /// what the pager's `jumpToIndex` binding expects; `current` is the index the pager is
    /// showing, so it gets a checkmark. Tapping a row jumps the pager and dismisses the popover.
    @ViewBuilder
    private func periodMenu<P: PeriodType>(
        _ type: P.Type,
        title: String,
        current: Int,
        jump: Binding<Int?>,
        dismiss: @escaping () -> Void
    ) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, .space4)
                    .padding(.top, 12)
                    .padding(.bottom, 4)

                ForEach(Array(P.allCases.enumerated()), id: \.offset) { index, period in
                    Button {
                        jump.wrappedValue = index
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Text(period.title)
                            Spacer(minLength: 16)
                            Image(systemName: "checkmark")
                                .font(.footnote.weight(.semibold))
                                .opacity(index == current ? 1 : 0)
                        }
                        .foregroundStyle(index == current ? Colour.accent : .primary)
                        .padding(.horizontal, .space4)
                        .padding(.vertical, 11)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(index == current ? [.isButton, .isSelected] : .isButton)
                }
            }
            .padding(.vertical, 6)
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(width: 240)
        .frame(maxHeight: 360)
    }

    @ViewBuilder
    private func produceListNavigationView(title: String) -> some View {
        // Favourites is a standalone NavigationStack, which adds its own ~18pt large-title
        // margin on top of this inset — unlike the pager's nested stacks — so trim the inset
        // here to keep the heading aligned with the month/season titles.
        ProduceListNavigationView(title: title, titleLeadingPadding: 2) {
            ProduceList(
                produce: produceStore.favourites,
                parentTab: .favourites,
                selectedCategory: state.selectedCategory
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
        case .search:
            // The search tab opens on an empty query, so this is a prompt rather than a
            // "nothing found" message — that case is handled by the search-results copy.
            "Search for any produce"
        case .months, .seasons:
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
