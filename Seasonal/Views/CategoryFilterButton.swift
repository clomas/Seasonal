//
//  CategoryFilterButton.swift
//  Seasonal
//
//  Created by Clint Thomas on 1/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

/// Toolbar menu that filters the produce lists by category. The icon is the selected
/// category's; black normally, accent-tinted while a filter other than "All" is active.
@available(iOS 26.0, *)
struct CategoryFilterButton: View {

    @Binding var selectedCategory: ProduceCategory

    var body: some View {
        Menu {
            Picker("Filter by category", selection: $selectedCategory) {
                ForEach(ProduceCategory.allCases, id: \.self) { category in
                    Label {
                        Text(category.menuTitle)
                    } icon: {
                        Image(symbol: category.image)
                    }
                    .tag(category)
                }
            }
        } label: {
            Image(symbol: selectedCategory.image)
        }
        // Set here rather than inherited: the app-wide green tint would otherwise colour it
        // even when no filter is applied.
        .tint(isFiltering ? Colour.accent : .primary)
        .accessibilityLabel("Filter by category")
        .accessibilityValue(isFiltering ? selectedCategory.menuTitle : "All categories")
        .accessibilityHint("Filters the produce list by category")
        .accessibilityIdentifier("filterByCategoryButton")
    }

    private var isFiltering: Bool { selectedCategory != .all }
}

@available(iOS 26.0, *)
#Preview {
    CategoryFilterButton(selectedCategory: .constant(.all))
}
