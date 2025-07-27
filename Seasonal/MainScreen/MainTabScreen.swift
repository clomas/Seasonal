struct ProduceList: View {
	let produce: [ProduceModel]

	var body: some View {
		ZStack {
			Color(.systemBackground)
			List(produce, id: \.id) { item in
				ProduceCell(produce: item)
					.listRowSeparator(.visible)
			}
			.listStyle(.plain)
			.listRowInsets(.bottomPadding)
		}
	}
}
	//
	//  MainTabScreen.swift
	//  Seasonal
	//
	//  Created by Clint Thomas on 30/6/2025.
	//  Copyright © 2025 Clint Thomas. All rights reserved.
	//

import SwiftUI

struct MainTabScreen: View {

	enum Tabs: String, CaseIterable {
		case favourites, months, seasons, categories, search
	}

	enum ProduceFilter {
		case all
		case liked
		case season(Season) // or month(Int)
	}

	@EnvironmentObject var appCoordinator: AppCoordinator

	@State private var selectedTab: Tabs = .favourites // TODO: store previous?
	// TODO: This is unfortunate an int is stored?
	@State private var category: ViewDisplayed.ProduceCategory = .all
	@State private var isSearching = false
	@State private var searchString: String = ""
	@State private var showAlert: Bool = false

	var filteredProduce: [ProduceModel] {
		guard let produce: [ProduceModel] = appCoordinator.produceData else { return [] }

		return switch selectedTab {
		case .categories:
			produce.filter { $0.category == category }
		case .favourites:
			produce.filter { $0.liked }
		case .months:
			produce.filter {
				$0.months.contains(MonthOld(rawValue: Calendar.current.component(.month, from: Date())) ?? .december)
			}
				//		case .all:
				//			produce
				//		case .liked:
				//			produce.filter { $0.liked }
				//		case .season(let season):
				//			produce.filter { $0.seasons.contains(season) }
		case .seasons:
			produce.filter { $0.seasons.contains(.autumn) }
		case .search:
			produce.filter { searchString.contains($0.name) }
		}
	}

	var body: some View {
		ZStack {
			if #available(iOS 18.0, *) {
				TabView(selection: $selectedTab) {
					Tab("Favourites", systemImage: "heart", value: MainTabScreen.Tabs.favourites) {
						ProduceList(produce: filteredProduce)
					}
					Tab("Months", systemImage: "calendar", value: MainTabScreen.Tabs.months) {
						ProduceList(produce: filteredProduce)
					}
					Tab("Seasons", systemImage: "cloud.sun", value: MainTabScreen.Tabs.seasons) {
						ProduceList(produce: filteredProduce)
					}
					Tab("Categories", systemImage: "slider.horizontal.2.square", value: MainTabScreen.Tabs.favourites) {
						ZStack {
							Color(.systemBackground)

							List(appCoordinator.produceData ?? [], id: \.id) { item in
								ProduceCell(produce: item)
									.listRowSeparator(.visible)
							}
							.listStyle(.plain)
							.listRowInsets(.bottomPadding)
								//						.padding(.leading, 100)
						}
						.edgesIgnoringSafeArea(.bottom)
					}
					Tab(value: .search, role: .search) {
						NavigationStack {
//							ProduceList(appCoordinator: _appCoordinator)
//								.searchable(text: $searchString)
						}
					}
				}
				// TODO: different colour here.
				.tint(Colour.inSeason)
			} else {
					// TODO: ? Fallback on earlier versions
			}
				// TODO: Whats going on here?
			FloatingSearchButton(isSearching: $isSearching)
		}

		.alert("Title", isPresented: $showAlert) {
			Text("Message")
			Button("OK", role: .cancel) { }
		}
	}
}

//struct ProduceList: View {
//
//	@EnvironmentObject var appCoordinator: AppCoordinator
//
//	var body: some View {
//			//		ZStack {
//			//			Color(.systemBackground)
//		List(appCoordinator.produceData ?? [], id: \.id) { item in
//			ProduceCell(produce: item)
//				.listRowSeparator(.visible)
//		}
//		.listStyle(.plain)
//		.listRowInsets(.bottomPadding)
//	}
//}

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
				months: [.june, .september],
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
