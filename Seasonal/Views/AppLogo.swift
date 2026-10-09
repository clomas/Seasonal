//
//  AppLogo.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

struct AppLogo: View {

    private let size: CGFloat = 150

    var body: some View {
        Image(.logo)
            .resizable()
            .frame(width: size, height: size)
            .padding()
            .accessibilityHidden(true)
    }
}

#Preview {
    AppLogo()
}
