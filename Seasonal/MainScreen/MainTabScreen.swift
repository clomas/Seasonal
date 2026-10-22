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

    @State private var state = MainScreenState()
    @State private var showTip = GlobalSettings.isSwipeTipDue
    @State private var isShowingSettings = false

    private let tipDismissDelay: Duration = .milliseconds(500)
    private let tipFadeDuration: TimeInterval = 1.5

    var body: some View {
        TabView(selection: $state.selectedTab) {
            Tab(Tabs.favourites.title, systemImage: Symbol.favourites, value: .favourites) {
                produceTab(for: .favourites)
            }
            Tab(Tabs.months.title, systemImage: Symbol.months, value: .months) {
                produceTab(for: .months)
            }
            Tab(Tabs.seasons.title, systemImage: Symbol.seasons, value: .seasons) {
                produceTab(for: .seasons)
            }
            Tab(Tabs.search.title, systemImage: Symbol.search, value: .search, role: .search) {
                produceTab(for: state.searchOrigin, isSearchable: true)
            }
        }
        .accessibilityIdentifier("mainTabView")
        .tabViewSearchActivation(.searchTabSelection)
        .tint(Colour.inSeason)
        .onChange(of: state.selectedTab) { _, newTab in
            StoredSelectedTab.storeTab(newTab)
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsModalScreen()
        }
        .overlay {
            if showTip, let tip {
                TipViewBlockingOverlay(tip: tip, onDismiss: hideTip)
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

    private func produceTab(for tab: Tabs, isSearchable: Bool = false) -> ProduceTabView {
        ProduceTabView(tab: tab, isSearchable: isSearchable, onPeekFinished: peekFinishedHandler, onShowSettings: showSettings)
    }

    private func showSettings() {
        isShowingSettings = true
    }

    private func dismissTipAfterPeek() async {
        try? await Task.sleep(for: tipDismissDelay)
        hideTip()
        GlobalSettings.markSwipeTipShown()
    }

    private func hideTip() {
        withAnimation(.easeInOut(duration: tipFadeDuration)) {
            showTip = false
        }
    }
}

#if DEBUG
@available(iOS 26, *)
#Preview {
    MainTabScreen()
        .environment(previewCoordinator)
        .environment(previewCoordinator.produceStore)
}
#endif
