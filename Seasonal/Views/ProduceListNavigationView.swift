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
	/// Leading inset for the large title. The pager's per-cell `NavigationStack`s sit at 0
	/// system margin, but a standalone `NavigationStack` (e.g. Favourites) adds ~18pt of its
	/// own large-title margin — so that call site passes a smaller value to line the titles up.
	var titleLeadingPadding: CGFloat = 20
	let content: Content

	init(title: String, titleLeadingPadding: CGFloat = 20, @ViewBuilder content: () -> Content) {
		self.title = title
		self.titleLeadingPadding = titleLeadingPadding
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
                            .padding(.leading, titleLeadingPadding)
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

