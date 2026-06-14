//
//  TabBarFilterButton.swift
//  Seasonal
//
//  Created by Clint Thomas on 1/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26.0, *)
struct TabBarFilterButton: View {

    @Binding var selectedCategory: ProduceCategory

    @State private var isPresented = false

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            isPresented = true
        } label: {
            menuIcon
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Filter by category")
        .accessibilityValue(isFiltering ? selectedCategory.title : "All categories")
        .accessibilityHint("Filters the produce list by category")
        .accessibilityIdentifier("filterByCategoryButton")
        // A popover honours the anchor (unlike `Menu`, which overlays the button): at the
        // bottom of the screen it's forced upward, so it sits above the button with its arrow
        // meeting the button's top edge. `.popover` adaptation keeps it a popover on iPhone
        // instead of collapsing to a sheet.
        .popover(isPresented: $isPresented, arrowEdge: .top) {
            categoryPicker
                .presentationCompactAdaptation(.popover)
        }
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(ProduceCategory.allCases, id: \.self) { category in
                Button {
                    selectedCategory = category
                    isPresented = false
                } label: {
                    HStack(spacing: 12) {
                        Label(category.title, systemImage: category.image)
                            .labelStyle(.titleAndIcon)
                        Spacer(minLength: 16)
                        Image(systemName: "checkmark")
                            .font(.footnote.weight(.semibold))
                            .opacity(selectedCategory == category ? 1 : 0)
                    }
                    .foregroundStyle(selectedCategory == category ? Colour.inSeason : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedCategory == category ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(.vertical, 6)
        .frame(minWidth: 220)
    }

    private var isFiltering: Bool { selectedCategory != .all }

    @ViewBuilder
    private var menuIcon: some View {
        VStack(spacing: 2) {
            Image(systemName: selectedCategory.image)
                .font(.system(.title3, weight: .medium))
            Text(selectedCategory.title)
                .font(.system(.caption2, weight: .medium))
                .lineLimit(1)
        }
        .foregroundStyle(isFiltering ? Colour.inSeason : Color.secondary)
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .glassEffect(.regular.interactive(), in: Capsule())
        .contentShape(Capsule())
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        ZStack {
            Colour.background
            TabBarFilterButton(selectedCategory: .constant(.all))
        }
            
    }
}
