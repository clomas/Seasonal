//
//  TabBarSearchButton.swift
//  Seasonal
//
//  Created by Clint Thomas on 13/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

/// The search control inside `LiquidGlassTabBar`. Collapsed it is an icon-over-label capsule
/// that matches the tab and filter items; tapping it morphs into a full-width search field
/// (the two shapes share a `glassEffectID`). It does **not** own a `GlassEffectContainer` —
/// the bar provides one (and the namespace) so this control blends into the same liquid-glass
/// surface as the tabs and filter controls.
@available(iOS 26.0, *)
struct TabBarSearchButton: View {

    @Binding var isSearching: Bool
    @Binding var query: String
    let namespace: Namespace.ID

    @FocusState private var focused: Bool

    private let glassID = "tabBarSearch"

    var body: some View {
        Group {
            if isSearching {
                expandedField
            } else {
                collapsedButton
            }
        }
        .onChange(of: isSearching) { _, searching in
            focused = searching
            if !searching { query = "" }
        }
    }

    private var collapsedButton: some View {
        Button(action: searchOpened) {
            VStack(spacing: 2) {
                Image.magnifyingGlass
                    .font(.system(.title3, weight: .medium))
                Text("Search")
                    .font(.system(.caption2, weight: .medium))
            }
            .foregroundStyle(.secondary)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: Capsule())
        .glassEffectID(glassID, in: namespace)
        .accessibilityIdentifier("searchButton")
        .accessibilityLabel("Search")
        .accessibilityHint("Opens the produce search field")
        .accessibilityAddTraits(.isButton)
    }

    private var expandedField: some View {
        HStack(spacing: 12) {
            Image.magnifyingGlass
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            TextField("Search produce", text: $query)
                .textFieldStyle(.plain)
                .focused($focused)
                .submitLabel(.search)
                .autocorrectionDisabled()
                .accessibilityIdentifier("searchField")
                .accessibilityLabel("Search produce")

            Button(action: searchClosed) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close search")
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .glassEffect(.regular, in: Capsule())
        .glassEffectID(glassID, in: namespace)
    }

    private func searchOpened() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            isSearching = true
        }
    }

    private func searchClosed() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        query = ""
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            isSearching = false
        }
    }
}
