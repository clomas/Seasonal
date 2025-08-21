//
//  Untitled.swift
//  Seasonal
//
//  Created by Clint Thomas on 21/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

struct TransparentBackgroundNavigationStack<Content: View>: View {
	let content: () -> Content

	var body: some View {
		NavigationStack {
			content()
		}
		.toolbarBackground(.visible, for: .navigationBar)
		.toolbarBackground(Color.clear, for: .navigationBar)
	}
}

