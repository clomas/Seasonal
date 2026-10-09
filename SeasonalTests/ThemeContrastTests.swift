//
//  ThemeContrastTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 4/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI
import Testing
@testable import Seasonal

/// WCAG 2.2 AA: 4.5:1 for text, which is the stricter bar every accent pair is held to.
@MainActor
struct ThemeContrastTests {

    private let minimumContrast = 4.5

    @Test(arguments: Theme.allCases.filter { $0 != .automatic })
    func accentIsLegibleAsTextOnSystemBackgrounds(_ theme: Theme) {
        let backgrounds: [UIColor] = [.systemBackground, .systemGroupedBackground, .secondarySystemGroupedBackground]
        for traits in appearances {
            let accent = UIColor(theme.accent).resolvedColor(with: traits)
            for background in backgrounds {
                let ratio = contrast(accent, background.resolvedColor(with: traits))
                #expect(ratio >= minimumContrast, "accent on \(background) \(describe(traits))")
            }
        }
    }

    @Test(arguments: Theme.allCases.filter { $0 != .automatic })
    func onAccentIsLegibleOnAccent(_ theme: Theme) {
        for traits in appearances {
            let ratio = contrast(
                UIColor(theme.onAccent).resolvedColor(with: traits),
                UIColor(theme.accent).resolvedColor(with: traits)
            )
            #expect(ratio >= minimumContrast, "onAccent on accent \(describe(traits))")
        }
    }

    @Test func everySeasonMapsToADistinctConcreteTheme() {
        let themes = Seasons.allCases.map { Theme(season: $0) }

        #expect(themes.contains(.automatic) == false)
        #expect(Set(themes).count == Seasons.allCases.count)
    }

    @Test(arguments: [
        (Appearance.automatic, ColorScheme?.none),
        (.light, .light),
        (.dark, .dark)
    ])
    func appearanceColorScheme(_ appearance: Appearance, expected: ColorScheme?) {
        #expect(appearance.colorScheme == expected)
    }

    // MARK: - Helpers

    private var appearances: [UITraitCollection] {
        [UIUserInterfaceStyle.light, .dark].flatMap { style in
            [UIAccessibilityContrast.normal, .high].map { contrast in
                UITraitCollection { traits in
                    traits.userInterfaceStyle = style
                    traits.accessibilityContrast = contrast
                }
            }
        }
    }

    private func describe(_ traits: UITraitCollection) -> String {
        "(\(traits.userInterfaceStyle == .dark ? "dark" : "light"), \(traits.accessibilityContrast == .high ? "high contrast" : "normal"))"
    }

    private func contrast(_ first: UIColor, _ second: UIColor) -> Double {
        let lighter = max(luminance(first), luminance(second))
        let darker = min(luminance(first), luminance(second))
        return (lighter + 0.05) / (darker + 0.05)
    }

    private func luminance(_ colour: UIColor) -> Double {
        let srgb = CGColorSpace(name: CGColorSpace.sRGB)!
        let components = colour.cgColor.converted(to: srgb, intent: .defaultIntent, options: nil)?.components ?? [0, 0, 0]
        let linear = components.prefix(3).map { channel -> Double in
            let value = Double(channel)
            return value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear[0] + 0.7152 * linear[1] + 0.0722 * linear[2]
    }
}
