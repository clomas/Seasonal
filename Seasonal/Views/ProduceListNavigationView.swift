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

	init(title: String, @ViewBuilder content: () -> Content) {
		self.title = title
		self.content = content()
	}

	var body: some View {
		NavigationStack {
			content
				.navigationTitle(title)
                .navigationBarTitleDisplayMode(.automatic)
                .toolbar {
                    ToolbarItem(placement: .largeTitle) {
                        Text(title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                    }
                }
		}
	}
}

@available(iOS 26, *)
#Preview {
	ProduceListNavigationView(title: "January") {
		ScrollView {
			LazyVStack(spacing: 12) {
				ForEach(Array(0..<40), id: \.self) { index in
					RoundedRectangle(cornerRadius: 12)
						.fill(.black)
						.frame(height: 80)
						.overlay(
							Text("Item \(index)")
								.foregroundStyle(.white)
								.font(.headline)
						)
						.padding(.horizontal)
				}
			}
		}
	}
}

