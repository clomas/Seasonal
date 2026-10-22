//
//  Image+Swatch.swift
//  Seasonal
//
//  Created by Clint Thomas on 22/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

@MainActor
extension Image {
    // Menus redraw symbol images as monochrome templates, even tinted ones, and ignore dynamic
    // image variants, so the swatch is flattened into a bitmap for the caller's appearance.
    // Menu picker values sit the image flush against the title, so the bitmap carries the gap.
    init(swatch colour: ColorResource, scheme: ColorScheme, contrast: ColorSchemeContrast) {
        let configuration = UIImage.SymbolConfiguration(textStyle: .body, scale: .small)
        let symbol = UIImage(systemName: Symbol.swatch, withConfiguration: configuration) ?? UIImage()
        let traits = UITraitCollection {
            $0.userInterfaceStyle = scheme == .dark ? .dark : .light
            $0.accessibilityContrast = contrast == .increased ? .high : .normal
        }
        let resolved = UIColor(resource: colour).resolvedColor(with: traits)
        let size = CGSize(width: symbol.size.width + .space1, height: symbol.size.height)
        let bitmap = UIGraphicsImageRenderer(size: size).image { _ in
            symbol.withTintColor(resolved).draw(at: .zero)
        }
        self.init(uiImage: bitmap)
    }
}
