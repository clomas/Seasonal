//
//  View+ToolbarTitleMenuIfPresent.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

extension View {
    /// Needed because an empty `toolbarTitleMenu` still draws its chevron.
    @ViewBuilder
    func toolbarTitleMenuIfPresent<Menu: View>(_ menu: Menu?) -> some View {
        if let menu {
            toolbarTitleMenu { menu }
        } else {
            self
        }
    }
}
