//
//  FloatingCategoryButton.swift
//  Seasonal
//
//  Created by Clint Thomas on 1/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26.0, *)
struct FloatingCategoryButton: View {

    @Binding var selectedCategory: ProduceCategory

    var body: some View {
        Menu {
            Picker("Category", selection: $selectedCategory) {
                ForEach(ProduceCategory.allCases, id: \.self) { category in
                    Label(category.title, systemImage: category.image)
                        .tag(category)
                        .foregroundStyle(selectedCategory == category ? Colour.inSeason : .primary)
                }
            }
        } label: {
            menuIcon
        }
        .accessibilityLabel("Filter by category")
        .controlSize(.large)
    }

    @ViewBuilder
    private var menuIcon: some View {
        Image(systemName: selectedCategory.image)
            .symbolRenderingMode(.hierarchical)
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(Colour.inSeason)
            .padding(18)
            .glassEffect(.regular.interactive(), in: Circle())
            .clipShape(Circle())
            .contentShape(Circle())
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        ZStack {
            Colour.background
            FloatingCategoryButton(selectedCategory: .constant(.all))
        }
            
    }
}
