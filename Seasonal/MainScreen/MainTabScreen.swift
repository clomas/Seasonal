//
//  MainTabScreen.swift
//  Seasonal
//
//  Created by Clint Thomas on 30/6/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

struct MainTabScreen: View {
	@EnvironmentObject var appCoordinator: AppCoordinator

	@State private var selectedTab = 0
	@State private var showErrorSheet = false

	@State private var showAlert: Bool = false

	var alertStrings: (title: String, message: String) {
		switch appCoordinator.state {
		case .networkFailed:
			(title: "Network Error", message: "Unable to connect to the internet")
		case .locationNotFound:
			(title: "Undetermined Location", message: "Choose your location")
		default:
			(title: "Sorry", message: "Something went wrong")
		}
	}

	var body: some View {
//		switch appCoordinator.state {
//		case .dataIsReady:
//			ZStack {}
//		case .networkFailed:
//			ZStack {}
//		case .locationNotFound:
//			ZStack {}
//		case .initial:
//			ZStack {}
//		}
		ZStack {
			TabView(selection: $selectedTab) {
				ForEach(0..<3) { index in
					Text("Tab \(index + 1)")
						.tabItem {
							Label("Tab \(index + 1)", systemImage: "square")
						}
						.tag(index)
				}
			}
			.padding(.trailing, 80)

			// Floating Search Button
			VStack {
				Spacer()
				HStack {
					Spacer()

					Button(action: {
//						showSearch.toggle()
						UIImpactFeedbackGenerator(style: .light).impactOccurred()
					}) {
						Image(systemName: "magnifyingglass")
							.font(.system(size: 22, weight: .medium))
							.foregroundStyle(.primary)
							.padding(20)
							.background(.ultraThinMaterial, in: Circle())
							.shadow(radius: 4)
					}
					.padding(.bottom, 20)
					.padding(.trailing, 24)
					.accessibilityLabel("Search")
				}
			}
			.ignoresSafeArea(edges: .bottom)
		}
		.alert("Title", isPresented: $showAlert) {
			Text("Message")
			Button("OK", role: .cancel) { }
		}
		.sheet(isPresented: $showErrorSheet) {
			SearchView()
		}

	}
}

struct SearchView: View {
	var body: some View {
		NavigationView {
			List {
				Text("Recent searches")
				Text("Trending items")
			}
			.navigationTitle("Search")
		}
	}
}

#Preview {
	MainTabScreen()
}
