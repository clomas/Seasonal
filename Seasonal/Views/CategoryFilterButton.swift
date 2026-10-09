//
//  CategoryFilterButton.swift
//  Seasonal
//
//  Created by Clint Thomas on 1/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26.0, *)
struct CategoryFilterButton: View {

    @Binding var selectedCategory: ProduceCategory

    var body: some View {
        Menu {
            Picker(Strings.Filter.label, selection: $selectedCategory) {
                ForEach(ProduceCategory.allCases, id: \.self) { category in
                    Label {
                        Text(category.title)
                    } icon: {
                        Image(symbol: category.image)
                    }
                    .tag(category)
                }
            }
        } label: {
            Label {
                Text(Strings.Filter.label)
            } icon: {
                Image(symbol: selectedCategory.image)
            }
        }
        .tint(isFiltering ? Colour.accent : .primary)
        .accessibilityValue(isFiltering ? selectedCategory.title : Strings.Filter.allCategories)
        .accessibilityHint(Strings.Filter.hint)
        .accessibilityIdentifier("filterByCategoryButton")
    }

    private var isFiltering: Bool {
        selectedCategory != .all
    }
}

@available(iOS 26.0, *)
#Preview {
    CategoryFilterButton(selectedCategory: .constant(.all))
}
