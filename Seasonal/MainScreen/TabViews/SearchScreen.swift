//
//  SearchScreen.swift
//  Seasonal
//
//  Created by Clint Thomas on 26/7/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

/// The content behind the `Tab(role: .search)`. The search field itself belongs to the tab bar,
/// not to this view — `MainTabScreen` puts `.searchable` on the `TabView`, which is what anchors
/// the field to the bottom and floats it above the keyboard.
///
/// Results span the whole catalogue rather than the month or season being browsed, so finding
/// something doesn't depend on already standing in the right period. The category filter still
/// applies, which is why it moves into the top-right chrome while this tab is up.
@available(iOS 26, *)
struct SearchScreen: View {

    @EnvironmentObject private var produceStore: ProduceStore
    @Environment(MainScreenState.self) private var state

    var body: some View {
        @Bindable var state = state
        NavigationStack {
            ProduceList(
                produce: produceStore.search(state.searchQuery),
                parentTab: .search,
                selectedCategory: state.selectedCategory,
                searchText: state.searchQuery
            )
            // Applied inside this tab rather than on the `TabView`: put on the TabView it gets
            // claimed by whichever tab's `NavigationStack` is showing and renders as a field at
            // the top of that page. Scoped here, it pairs with the tab's `.search` role so the
            // system anchors it to the bottom bar and lifts it above the keyboard.
            .searchable(text: $state.searchQuery, prompt: "Search produce")
        }
    }
}

@available(iOS 26, *)
#Preview {
    SearchScreen()
        .environmentObject(previewCoordinator)
        .environmentObject(previewCoordinator.produceStore)
        .environment(MainScreenState())
}
