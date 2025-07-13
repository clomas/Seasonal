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
	@State private var isSearching = false

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
//								.listRowSeparator(.hidden)
//								.listRowBackground(Color(.systemBackground))
//							Text("Something really long long long long lon")
								.listRowSeparator(.visible)
						}
						.listStyle(.plain)
						.listRowInsets(.bottomPadding)
					}
//
					.edgesIgnoringSafeArea(.bottom)
					.tabItem {
						Label("Tab \(index + 1)", systemImage: "square")
					}
					.tag(index)
				}
			}
//			.padding(.trailing, 85)
			.padding(.bottom, isSearching ? 100 : 0)

			FloatingSearchButton(isSearching: $isSearching)
		}
		.alert("Title", isPresented: $showAlert) {
			Text("Message")
			Button("OK", role: .cancel) { }
		}
		.sheet(isPresented: $isSearching) {
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
				name: "Apples",
				category: .fruit,
				imageName: "Apples",
				description: "",
				months: [.april, .august, .december, .january, .june, .september],
				seasons: [.autumn, .spring],
				liked: true
			),
			ProduceModel(
				id: 1,
				name: "Bananas",
				category: .fruit,
				imageName: "Bananas",
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
