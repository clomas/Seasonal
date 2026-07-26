//
//  MainScreenTabBar.swift
//  Seasonal
//
//  Created by Clint Thomas on 13/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

/// A custom liquid-glass bottom bar that replaces the native iOS 26 tab bar (which is hidden
/// via `.toolbarVisibility(.hidden, for: .tabBar)`). It owns its own width and layout, so the
/// search and category controls sit cohesively alongside the tabs. Selection is driven back
/// into the underlying `TabView` through the `selectedTab` binding.
///
/// Collapsed it shows: search · tabs · filter. Tapping search collapses the tabs to zero
/// width and expands the field to fill, while keyboard avoidance floats the whole bar up.
@available(iOS 26, *)
struct MainScreenTabBar: View {

    @Environment(MainScreenState.self) private var state

    @EnvironmentObject private var featureToggleHelper: FeatureToggleHelper

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Namespace private var glassNamespace
    @Namespace private var tabNamespace

    /// Drops the text labels for an icon-only look either once the launch-count feature toggle
    /// enables it, or when Dynamic Type reaches `.xLarge` (where the labels would otherwise cram).
    /// With labels hidden, long-pressing a tab still surfaces its name via the large content viewer.
    private var hideLabels: Bool {
        featureToggleHelper.isEnabled(.hideTabBarLabels) || dynamicTypeSize >= .xLarge
    }

    var body: some View {
        @Bindable var state = state
        // One container so the search, tabs and filter glass surfaces blend into a single
        // connected cluster (and the search morph animates within it).
        GlassEffectContainer(spacing: 18) {
            HStack(spacing: 6) {
                TabBarSearchButton(
                    isSearching: $state.isSearching,
                    query: $state.searchQuery,
                    namespace: glassNamespace,
                    hideLabel: hideLabels
                )
                .frame(maxWidth: state.isSearching ? .infinity : nil)

                if !state.isSearching {
                    tabCluster
                }

                TabBarFilterButton(selectedCategory: $state.selectedCategory, hideLabel: hideLabels)
            }
            // Let the bar respond to Dynamic Type, but cap it so large accessibility sizes
            // don't blow out its height the way unbounded scaling would.
            .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        }
    }

    private var tabCluster: some View {
        HStack(spacing: 2) {
            tabButton(.favourites, icon: "heart", label: "Favourites")
            tabButton(.months(Months.currentPeriod), icon: "calendar", label: "Months")
            tabButton(.seasons(Seasons.currentPeriod), icon: "cloud.sun", label: "Seasons")
        }
        .padding(6)
        .glassEffect(.regular, in: Capsule())
        // Participate in the container's glass morph so the cluster flows in/out of the merged
        // surface. A plain scale/opacity transition instead grows it from zero in the middle,
        // which reads as the tab bar joining the side buttons late when search closes.
        .glassEffectID("tabCluster", in: glassNamespace)
    }

    private func tabButton(_ tab: MainTabScreen.Tabs, icon: String, label: String) -> some View {
        let selected = isSelected(tab)
        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                state.selectedTab = tab
            }
        } label: {
            VStack(spacing: 2) {
                Image(symbol: icon)
                    .font(.system(hideLabels ? .title2 : .title3, weight: .medium))
                if !hideLabels {
                    Text(label)
                        .font(.tabCaption)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .foregroundStyle(selected ? .primary : .secondary)
            // Reclaim the space the label used to take as touch padding, so icon-only buttons
            // keep a comfortable target instead of shrinking. Matching horizontal to vertical
            // keeps the shape roughly square, so the Capsule reads as a ~height/2 radius pill.
            .padding(.vertical, hideLabels ? 16 : 8)
            .padding(.horizontal, hideLabels ? 16 : 10)
            .background {
                if selected {
                    Capsule()
                        .fill(Colour.accentHighlight)
                        .matchedGeometryEffect(id: "tabHighlight", in: tabNamespace)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        // Restores the native tab bar's long-press behaviour: at accessibility text sizes,
        // holding a tab shows an enlarged icon + name HUD. The custom bar doesn't get this
        // for free, and it's the discovery path once labels are hidden at large type.
        .accessibilityShowsLargeContentViewer {
            Label(label, systemImage: icon)
        }
        .accessibilityIdentifier("tab-\(label)")
        .accessibilityLabel(label)
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
    }

    private func isSelected(_ tab: MainTabScreen.Tabs) -> Bool {
        switch (state.selectedTab, tab) {
        case (.favourites, .favourites), (.months, .months), (.seasons, .seasons):
            true
        default:
            false
        }
    }
}
