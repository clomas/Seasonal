//
//  CustomNavigationView.swift
//  Seasonal
//
//  Created by Clint Thomas on 9/11/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

@available(iOS 26, *)
struct ProduceListNavigationView<Content: View>: View {
	let title: String
	let content: Content

	var navigationViewButtonTapped: Closure? = nil

	init(title: String, @ViewBuilder content: () -> Content) {
		self.title = title
		self.content = content()
	}

	var body: some View {
		ZStack(alignment: .top) {
			content
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			HStack {
				Text(title)
					.font(.largeTitle)
					.bold()
				Spacer()
				if navigationViewButtonTapped != nil {
					Button {
						navigationViewButtonTapped?()
					} label: {
						Image(systemName: "calendar")
							.font(.system(size: 20, weight: .semibold))
							.symbolRenderingMode(.hierarchical)
							.foregroundStyle(.primary)
					}
					.buttonStyle(.plain)
					.contentShape(Rectangle())
				}
			}
			.padding(.horizontal)
			.padding(.top, 40)
			.background(Color.clear)
		}
	}
}
