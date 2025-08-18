	//
	//  MainTabScreen.swift
	//  Seasonal
	//
	//  Created by Clint Thomas on 30/6/2025.
	//  Copyright © 2025 Clint Thomas. All rights reserved.
	//

import SwiftUI

struct MainTabScreen: View {

	enum MainTabScreenTab: Hashable {
		case favourites
		case months
		case seasons
		case categories
		case search
	}

	@State private var selectedTab: MainTabScreenTab = .favourites
	@EnvironmentObject var appCoordinator: AppCoordinator

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
		.tag(Tabs.favourites(category: .all, search: ""))
	}

	var body: some View {
		ZStack {
			TabView(selection: $selectedTab) {
				Tab("Favourites", systemImage: "heart", value: .favourites) {
					ProduceList(produce: produce)
				}
				Tab("Months", systemImage: "calendar", value: .months) {
					NavigationStack {
						MonthsTabView(
							selectedMonth: Month.thisMonth,
							produce: produce
						)
					}
					.toolbarBackground(.visible, for: .navigationBar)
					.toolbarBackground(Color.clear, for: .navigationBar)
				}
				Tab("Seasons", systemImage: "cloud.sun", value: .seasons) {
					ProduceList(produce: produce)
				}
				Tab("Categories", systemImage: "slider.horizontal.2.square", value: .categories) {
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
				Tab(value: .search, role: .search) {
					NavigationStack {
							//							ProduceList(appCoordinator: _appCoordinator)
							//								.searchable(text: $searchString)
					}
				}
			}
			.onChange(of: $selectedTab.wrappedValue) { _, newValue in
				if case .months = newValue {

					// TODO: Handling here
//					if case let .months(currentMonth, currentCategory, search) = appCoordinator.viewContext {
//							// Already on months, do nothing
//					} else {
//						appCoordinator.viewContext = .months(.thisMonth, category: .all, search: "")
//					}
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
