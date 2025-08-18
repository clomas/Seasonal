	//
	//  MainTabScreen.swift
	//  Seasonal
	//
	//  Created by Clint Thomas on 30/6/2025.
	//  Copyright © 2025 Clint Thomas. All rights reserved.
	//

import SwiftUI

struct MainTabScreen: View {

	enum Tabs: Hashable {
		case favourites(category: ViewDisplayed.ProduceCategory = .all, search: String)
		case months(Month, category: ViewDisplayed.ProduceCategory = .all, search: String)
		case seasons(Season, category: ViewDisplayed.ProduceCategory = .all, search: String)
			//		case categories(ViewDisplayed.ProduceCategory)
			//		case search(String = "")

		var title: String {
			switch self {
			case .favourites:
				"Favourites"
			case .months(let month, _, _):
				month.name
			case .seasons(let season, _, _):
				season.name
					//			case .categories(let category):
					//				return categoryTitle(category)
					//			case .search:
					//				return "Search"
			}
		}

		private func categoryTitle(_ category: ViewDisplayed.ProduceCategory) -> String {
			switch category {
			case .all: "All"
			case .fruit: "Fruit"
			case .vegetables: "Vegetables"
			case .herbs: "Herbs"
			case .cancelled: "Cancelled"
			}
		}
	}

	@EnvironmentObject var appCoordinator: AppCoordinator

		// selectedTab is now a computed binding to appCoordinator.viewContext
	private var selectedTab: Binding<Tabs> { $appCoordinator.viewContext }
	@State private var category: ViewDisplayed.ProduceCategory = .all
	@State private var isSearching = false
	@State private var searchString: String = ""
	@State private var showAlert: Bool = false

	private var produce: [ProduceModel] {
		appCoordinator.produceData ?? []
	}

	var favourites: some View {
		NavigationStack {
			ProduceList(produce: produce)
				.navigationTitle("Favourites")
		}
		.tabItem {
			Label("Favourites", systemImage: "heart")
		}
		.tag(MainTabScreen.Tabs.favourites(category: .all, search: ""))
	}

	var body: some View {
		ZStack {
			TabView(selection: selectedTab) {
				Tab("Favourites", systemImage: "heart", value: MainTabScreen.Tabs.favourites(category: .all, search: "")) {
					ProduceList(produce: produce)
				}
				Tab("Months", systemImage: "calendar", value: selectedTab.wrappedValue) {
					NavigationStack {
						MonthsTabView(produce: produce, selectedTab: $appCoordinator.viewContext)
					}
					.toolbarBackground(.visible, for: .navigationBar)
					.toolbarBackground(Color.clear, for: .navigationBar)
				}
				Tab("Seasons", systemImage: "cloud.sun", value: MainTabScreen.Tabs.seasons(.autumn, search: "")) {
					ProduceList(produce: produce)
				}
				Tab("Categories", systemImage: "slider.horizontal.2.square", value: MainTabScreen.Tabs.favourites(category: .all, search: "")) {
					ZStack {
						Color(.systemBackground)

						List(appCoordinator.produceData ?? [], id: \.id) { item in
							ProduceCell(produce: item)
								.listRowSeparator(.visible)
						}
						.listStyle(.plain)
						.listRowInsets(.bottomPadding)
					}
				}
				Tab(value: selectedTab.wrappedValue, role: .search) {
					NavigationStack {
							//							ProduceList(appCoordinator: _appCoordinator)
							//								.searchable(text: $searchString)
					}
				}
			}
				// TODO: different colour here.
			.tint(Colour.inSeason)
				// TODO: Whats going on here?
			FloatingSearchButton(isSearching: $isSearching)
		}

		.alert("Title", isPresented: $showAlert) {
			Text("Message")
			Button("OK", role: .cancel) { }
		}
	}

	init() {
		// TODO: This? nah
			//		UITabBar.appearance().backgroundColor = UIColor(Color.gray)
//		UITabBar.appearance().unselectedItemTintColor = .darkGray
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
		let coord = AppCoordinator(window: .create())
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
