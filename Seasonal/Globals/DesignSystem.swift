//
//  DesignSystem.swift
//  Seasonal
//
//  The app's shared design language: semantic typography, a spacing scale, and
//  small reusable components. All built on native system fonts (Dynamic Type)
//  and SF Symbols so the UI stays consistent and accessible by construction.
//
//  Colour tokens live alongside the `Colour` struct in GlobalSettings.swift.
//

import SwiftUI

// MARK: - Typography

/// Semantic text styles. Each maps to a system text style so it scales with
/// Dynamic Type automatically — never a fixed point size.
extension Font {
    /// Large navigation / screen titles.
    static let screenTitle = Font.largeTitle.bold()
    /// Section headers, e.g. "Choose your location".
    static let sectionTitle = Font.title3.weight(.semibold)
    /// Prominent item titles, e.g. produce names in a row.
    static let cardTitle = Font.title2
    /// Capsule / CTA button labels.
    static let buttonLabel = Font.headline
    /// Standard body copy, e.g. error messages.
    static let bodyText = Font.body
    /// Secondary labels, links, month letters.
    static let label = Font.subheadline
    /// Compact labels under tab-bar / toolbar icons.
    static let tabCaption = Font.caption2.weight(.medium)
}

// MARK: - Spacing

/// A 4pt spacing rhythm. Use these instead of ad-hoc literals so padding stays
/// consistent across the app.
extension CGFloat {
    static let space1: CGFloat = 4
    static let space2: CGFloat = 8
    static let space3: CGFloat = 12
    static let space4: CGFloat = 16
    static let space5: CGFloat = 20
    static let space6: CGFloat = 24
    static let space8: CGFloat = 32

    /// Diameter of an `AccentIconChip`.
    static let iconChip: CGFloat = 28
    /// Height of the months-in-season capsule row.
    static let capsuleRowHeight: CGFloat = 30
}

// MARK: - Components

/// An SF Symbol glyph centred in a solid accent-coloured circle. The glyph uses
/// `Colour.onAccent`, which is adaptive (white in light mode, near-black-green in
/// dark mode) so it stays legible against the accent fill in both appearances.
struct AccentIconChip: View {
    let systemImage: String
    var diameter: CGFloat = .iconChip

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: diameter * 0.5, weight: .semibold))
            .foregroundStyle(Colour.onAccent)
            .frame(width: diameter, height: diameter)
            .background(Circle().fill(Colour.accent))
    }
}

#Preview {
    VStack(spacing: .space4) {
        AccentIconChip(systemImage: "mappin.and.ellipse")
        AccentIconChip(systemImage: "arrow.clockwise")
        Text("screenTitle").font(.screenTitle)
        Text("sectionTitle").font(.sectionTitle)
        Text("cardTitle").font(.cardTitle)
        Text("buttonLabel").font(.buttonLabel)
        Text("label").font(.label)
    }
    .padding()
}
