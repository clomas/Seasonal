//
//  TabBarFilterButton.swift
//  Seasonal
//
//  Created by Clint Thomas on 1/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

/// The filter control inside `LiquidGlassTabBar`: an icon-over-label capsule that opens a category
/// picker as a popover *above* the bar.
///
/// The picker uses `arrowEdge: .bottom`, which puts the arrow on the popover's bottom edge and so
/// forces the content to open upward out of the button — the earlier `.top` did the opposite and
/// dropped the menu off-screen once the keyboard floated the bar up. `presentationCompactAdaptation`
/// keeps it a popover on iPhone instead of collapsing into a sheet.
@available(iOS 26.0, *)
struct TabBarFilterButton: View {

    @Binding var selectedCategory: ProduceCategory
    var hideLabel: Bool = false

    /// Same metric the other chrome buttons use, so all three scale together with Dynamic Type.
    @ScaledMetric(relativeTo: .title2) private var iconSize: CGFloat = 22

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
        .accessibilityValue(isFiltering ? selectedCategory.menuTitle : "All categories")
        .accessibilityHint("Filters the produce list by category")
        .accessibilityIdentifier("filterByCategoryButton")
        .popover(
            isPresented: $isPresented,
            attachmentAnchor: .point(.top),
            arrowEdge: .bottom
        ) {
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
                        Label {
                            Text(category.menuTitle)
                        } icon: {
                            Image(symbol: category.image)
                        }
                        .labelStyle(.titleAndIcon)
                        Spacer(minLength: 16)
                        Image(systemName: "checkmark")
                            .font(.footnote.weight(.semibold))
                            .opacity(selectedCategory == category ? 1 : 0)
                    }
                    .foregroundStyle(selectedCategory == category ? Colour.accent : .primary)
                    .padding(.horizontal, .space4)
                    .padding(.vertical, 11)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedCategory == category ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(.vertical, 6)
        .frame(width: 240)
    }

    private var isFiltering: Bool { selectedCategory != .all }

    /// Lit while a filter is active *or* the picker is open, so the green blob persists with the menu.
    private var isHighlighted: Bool { isFiltering || isPresented }

    @ViewBuilder
    private var menuIcon: some View {
        if hideLabel {
            // Chrome-sized glass circle, built the same way as `InfoButton` and
            // `SelectMonthButton` (22pt icon, 16pt padding) so it reads as one of the set and
            // matches the system search item it sits with.
            Image(symbol: selectedCategory.image)
                .font(.system(size: iconSize, weight: .medium))
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(isHighlighted ? AnyShapeStyle(Colour.accent) : AnyShapeStyle(.primary))
                .padding(16)
                .glassEffect(.regular.interactive(), in: Circle())
                .contentShape(Circle())
        } else {
            VStack(spacing: 2) {
                Image(symbol: selectedCategory.image)
                    .font(.system(.title3, weight: .medium))
                label
            }
            .foregroundStyle(isHighlighted ? .primary : .secondary)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            // Same green blob the selected tab uses, inset so it reads as a pill inside the
            // button rather than filling its whole bounds.
            .background {
                if isHighlighted {
                    Capsule()
                        .fill(Colour.accentHighlight)
                        .padding(6)
                }
            }
            .glassEffect(.regular.interactive(), in: Capsule())
            .contentShape(Capsule())
        }
    }

    /// Shows the current label but always reserves the width of the widest one (via hidden copies),
    /// so the button doesn't resize as the selection changes. Sizing from real text metrics keeps
    /// it correct under Dynamic Type.
    private var label: some View {
        ZStack {
            ForEach(ProduceCategory.allCases, id: \.self) { category in
                Text(category.buttonTitle).hidden()
            }
            Text(selectedCategory.buttonTitle)
        }
        .font(.tabCaption)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .accessibilityHidden(true)
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
