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
		case favourites
		case months
		case seasons
		case categories
		case search

		var title: String {
			switch self {
			case .favourites:
				"Favourites"
			case .months:
				"Months"
			case .seasons:
				"Seasons"
			default: // TODO: handle other cases?
				""
			}
		}
	}

	@EnvironmentObject var appCoordinator: AppCoordinator

	@State private var selectedTab: Tabs = .favourites
	@State private var previousTab: Tabs = .favourites
	@State private var originalTabBeforeCategories: Tabs = .favourites
	@State private var showCategoryMenu: Bool = false

	@State private var selectedCategory: ProduceCategory = .all

	@State private var searchString: String = ""
	@State private var showAlert: Bool = false
	@State private var isSearching = false

	private var produce: [ProduceModel] {
		appCoordinator.produceData ?? []
	}

	private var categoriesPopOverView: some View {
		ForEach(ProduceCategory.allCases, id: \.self) { category in
			Button(action: {
				selectedCategory = category
				showCategoryMenu = false
				selectedTab = previousTab
			}) {
				Label(category.title, systemImage: category.image)
					.padding()
					.tint(category == selectedCategory ? Colour.inSeason : .black)
			}
		}
		.presentationCompactAdaptation(.popover)
		.onAppear {
			originalTabBeforeCategories = previousTab
		}
		.onDisappear {
			selectedTab = originalTabBeforeCategories
			showCategoryMenu = false
		}
	}

	var tab: some View {
		MainTabScreenViewFactory.view(for: selectedTab == .categories ? previousTab : selectedTab, produce: produce)
	}

	var body: some View {
		ZStack {
			TabView(selection: $selectedTab) {
				Tab("Favourites", systemImage: "heart", value: .favourites) { tab }
				Tab("Months", systemImage: "calendar", value: .months) { tab }
				Tab("Seasons", systemImage: "cloud.sun", value: .seasons) {	tab }
				Tab("Categories", systemImage: .settings, value: .categories) { tab }
					.popover(isPresented: $showCategoryMenu) {
						categoriesPopOverView
					}
				Tab(value: .search, role: .search) {
					NavigationStack {
							//							ProduceList(appCoordinator: _appCoordinator)
							//								.searchable(text: $searchString)
					}
				}
			}
			.tint(Colour.inSeason)
		}
		.onChange(of: selectedTab) { oldTab, newTab in
			if newTab == .categories {
				showCategoryMenu.toggle()
			} else {
				previousTab = newTab
				showCategoryMenu = false
			}
		}
		.alert("Title", isPresented: $showAlert) {
			Text("Message")
			Button("OK", role: .cancel) { }
		}
	}

	private func createNavigationStackForPeriodView(_ view: some View) -> some View {
		NavigationStack { view }
			.toolbarBackground(.visible, for: .navigationBar)
			.toolbarBackground(Color.clear, for: .navigationBar)
	}
}

struct MainTabScreenViewFactory {
	@MainActor
	static func view(for tab: MainTabScreen.Tabs, produce: [ProduceModel]) -> AnyView {
		switch tab {
			case .favourites:
			AnyView(ProduceList(produce: produce, period: Months.april, selectedTab: tab))
			case .months:
			AnyView(
			NavigationStack {
				PeriodTabView<Months>(
				produce: produce,
				selectedPeriod: Months.currentPeriod
				)
			}
			.toolbarBackground(.visible, for: .navigationBar)
			.toolbarBackground(Color.clear, for: .navigationBar)
			)
			case .seasons:
			AnyView(
			NavigationStack {
				PeriodTabView<Seasons>(
				produce: produce,
				selectedPeriod: Seasons.currentPeriod
				)
			}
			.toolbarBackground(.visible, for: .navigationBar)
			.toolbarBackground(Color.clear, for: .navigationBar)
			)
			case .categories:
			AnyView(EmptyView())
			case .search:
			AnyView(EmptyView())
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
		months: [.april, .august, .december, .january, . june, .september],
		seasons: [.autumn, .spring],
		liked: true
		),
		ProduceModel(
		id: 0,
		name: "Apple",
		category: .fruit,
		imageName: "apple",
		description: "",
		months: [.april, .august, .december, .january, . june, .september],
		seasons: [.autumn, .spring],
		liked: true
		),
		ProduceModel(
		id: 0,
		name: "Apple",
		category: .fruit,
		imageName: "apple",
		description: "",
		months: [.april, .august, .december, .january, . june, .september],
		seasons: [.autumn, .spring],
		liked: true
		),
		ProduceModel(
		id: 0,
		name: "Apple",
		category: .fruit,
		imageName: "apple",
		description: "",
		months: [.april, .august, .december, .january, . june, .september],
		seasons: [.autumn, .spring],
		liked: true
		),
		ProduceModel(
		id: 0,
		name: "Apple",
		category: .fruit,
		imageName: "apple",
		description: "",
		months: [.april, .august, .december, .january, . june, .september],
		seasons: [.autumn, .spring],
		liked: true
		),
		]
		return coord
	}()

	MainTabScreen()
		.environmentObject(coord)
}
