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

		var lowercaseTitle: String {
			title.lowercased()
		}
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

	var body: some View {
		ZStack {
			TabView(selection: $selectedTab) {
				Tab("Favourites", systemImage: "heart", value: .favourites) {
					ProduceList(produce: produce, period: Months.april, selectedTab: selectedTab)
				}
				Tab("Months", systemImage: "calendar", value: .months) {
					createNavigationStackForPeriodView(for:
						PeriodTabView<Months>(
							produce: produce,
							selectedPeriod: Months.currentPeriod
						)
					)
				}
				Tab("Seasons", systemImage: "cloud.sun", value: .seasons) {
					createNavigationStackForPeriodView(for:
						PeriodTabView<Seasons>(
							produce: produce,
							selectedPeriod: Seasons.currentPeriod
						)
					)
				}
				Tab("Categories", systemImage: "slider.horizontal.2.square", value: .categories) {
//					ZStack {
//						Color(.systemBackground)
//
//						List(appCoordinator.produceData ?? [], id: \.id) { item in
//							ProduceCell(produce: item)
//								.listRowSeparator(.visible)
//						}
//						.listStyle(.plain)
//						.listRowInsets(.bottomPadding)
//					}
//					Menu {
//						ForEach(Array(Period.allCases), id: \.self) { period in
//							Button("\(period.name)") {
//								selectedPeriod = period
//							}
//						}
//					} label: {
//						Label(selectedPeriod.name, systemImage: .calendarImage)
//							.glassEffect(.regular)
//					}
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

	private func createNavigationStackForPeriodView(for view: some View) -> some View {
		NavigationStack { view }
			.toolbarBackground(.visible, for: .navigationBar)
			.toolbarBackground(Color.clear, for: .navigationBar)
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
