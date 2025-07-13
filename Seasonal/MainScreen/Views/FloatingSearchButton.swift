//
//  FloatingSearchButton.swift
//  Seasonal
//
//  Created by Clint Thomas on 13/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

struct FloatingSearchButton: View {

	@Binding var isSearching: Bool

	var body: some View {
		VStack {
			Spacer()
			HStack {
				Spacer()

				Button(action: {
					isSearching.toggle()
					UIImpactFeedbackGenerator(style: .light).impactOccurred()
				}) {
					if #available(iOS 26.0, *) {
						Image(systemName: "magnifyingglass")
							.font(.system(size: 22, weight: .medium))
							.foregroundStyle(.primary)
							.padding(16)
							.background(.ultraThinMaterial, in: Circle())
							.glassEffect(.regular)
					} else {
						Image(systemName: "magnifyingglass")
							.font(.system(size: 22, weight: .medium))
							.foregroundStyle(.primary)
							.padding(16)
							.background(.ultraThinMaterial, in: Circle())
					}
				}
				.foregroundStyle(.black)
				.padding(.bottom, 24)
				.padding(.trailing, 24)
				.accessibilityLabel("Search")
			}
		}
		.ignoresSafeArea(edges: .bottom)
	}
	
}
@available(iOS 26.0, *)
#Preview {
	@Previewable @State var isSearching: Bool = false
	FloatingSearchButton(isSearching: $isSearching)
}

