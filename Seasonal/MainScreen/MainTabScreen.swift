//
//  MainTabScreen.swift
//  Seasonal
//
//  Created by Clint Thomas on 30/6/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

struct MainTabScreen: View {

	enum ProduceFilter {
		case all
		case liked
		case season(Season) // or month(Int)
	}

	@EnvironmentObject var appCoordinator: AppCoordinator

	@State private var selectedTab = 0
	@State private var showErrorSheet = false

	@State private var showAlert: Bool = false

	@State private var selectedFilter: ProduceFilter = .all

	var filteredProduce: [ProduceModel] {
		guard let produce = appCoordinator.produceData else { return [] }

		return switch selectedFilter {
		case .all:
			produce
		case .liked:
			produce.filter { $0.liked }
		case .season(let season):
			produce.filter { $0.seasons.contains(season) }
		}
	}

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
		ZStack {
			TabView(selection: $selectedTab) {
				ForEach(0..<3, id: \.self) { index in
						// Use a ZStack to avoid vertical compression
					ZStack {
						Color(.systemBackground) // fix background glitches

						List(appCoordinator.produceData ?? [], id: \.id) { item in
							ProduceCell(produce: item)
//								.frame(height: .infinity)
						}
						.listStyle(.plain)
					}
					.edgesIgnoringSafeArea(.bottom)
					.tabItem {
						Label("Tab \(index + 1)", systemImage: "square")
					}
					.tag(index)
				}
			}

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
	lazy var coord: AppCoordinator = {
		let coord = AppCoordinator(window: UIWindow())
		coord.state = .locationNotFound
		coord.produceData = [
			ProduceModel(
				id: 0,
				name: "Apple",
				category: .fruit,
				imageName: "apple",
				description: "",
				months: [.april, .august, .december, .january, .june, .september],
				seasons: [.autumn, .spring],
				liked: true
			),
			ProduceModel(
				id: 0,
				name: "Apple",
				category: .fruit,
				imageName: "apple",
				description: "",
				months: [.april, .august, .december, .january, .june, .september],
				seasons: [.autumn, .spring],
				liked: true
			),
			ProduceModel(
				id: 0,
				name: "Apple",
				category: .fruit,
				imageName: "apple",
				description: "",
				months: [.april, .august, .december, .january, .june, .september],
				seasons: [.autumn, .spring],
				liked: true
			),
		]
		return coord
	}()

	MainTabScreen()
		.environmentObject(coord)
}
