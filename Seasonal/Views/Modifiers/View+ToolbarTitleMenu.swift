//
//  View+ToolbarTitleMenu.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

extension View {
    /// Needed because an empty `toolbarTitleMenu` still draws its chevron.
    @ViewBuilder
    func toolbarTitleMenu<Content: View>(isPresented: Bool, @ViewBuilder content: () -> Content) -> some View {
        if isPresented {
            toolbarTitleMenu(content: content)
        } else {
            self
        }
    }
}
