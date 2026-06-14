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

    @Binding var selectedTab: MainTabScreen.Tabs
    @Binding var isSearching: Bool
    @Binding var searchQuery: String
    @Binding var selectedCategory: ProduceCategory

    @Namespace private var glassNamespace
    @Namespace private var tabNamespace

    var body: some View {
        // One container so the search, tabs and filter glass surfaces blend into a single
        // connected cluster (and the search morph animates within it).
        GlassEffectContainer(spacing: 18) {
            HStack(spacing: 6) {
                TabBarSearchButton(
                    isSearching: $isSearching,
                    query: $searchQuery,
                    namespace: glassNamespace
                )
                .frame(maxWidth: isSearching ? .infinity : nil)

                if !isSearching {
                    tabCluster
                        .transition(.scale.combined(with: .opacity))
                }

                TabBarFilterButton(selectedCategory: $selectedCategory)
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
    }

    private func tabButton(_ tab: MainTabScreen.Tabs, icon: String, label: String) -> some View {
        let selected = isSelected(tab)
        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(.title3, weight: .medium))
                Text(label)
                    .font(.system(.caption2, weight: .medium))
            }
            .foregroundStyle(selected ? .primary : .secondary)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background {
                if selected {
                    Capsule()
                        .fill(Colour.inSeason.opacity(0.30))
                        .matchedGeometryEffect(id: "tabHighlight", in: tabNamespace)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("tab-\(label)")
        .accessibilityLabel(label)
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
    }

    private func isSelected(_ tab: MainTabScreen.Tabs) -> Bool {
        switch (selectedTab, tab) {
        case (.favourites, .favourites), (.months, .months), (.seasons, .seasons):
            true
        default:
            false
        }
    }
}
