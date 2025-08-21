	//
	//  MainTabScreen.swift
	//  Seasonal
	//
	//  Created by Clint Thomas on 30/6/2025.
	//  Copyright © 2025 Clint Thomas. All rights reserved.
	//

import SwiftUI

@available(iOS 26, *)
struct MainTabScreen: View {

	enum Tabs: Hashable {
		case favourites
		case period(AnyPeriod)
		case categories
		case search(AnyPeriod)

		var title: String {
			switch self {
			case .favourites:
				"Favourites"
			case .period(let period):
				switch period {
				case .months(let month):
					"Month"
				}
//				"Months/"
			case .seasons:
				"Seasons"
			default: // TODO: handle other cases
				""
			}
		}

		var emptyProduceListViewMessage: String? {
			return if case .favourites = self {
				"❤️ Favourite some produce to see it in here."
			} else {
				nil
			}
		}
	}

	@EnvironmentObject var appCoordinator: AppCoordinator

	// TODO: track last tab in user d's
	@State private var selectedTab: Tabs = .favourites
	@State private var previousTab: Tabs = .favourites
	@State private var originalTabBeforeCategories: Tabs = .favourites
	@State private var showCategoryMenu: Bool = false

	@State private var selectedCategory: ProduceCategory = .all

	@State private var searchString: String = ""
	@State private var showAlert: Bool = false
	@State private var isSearching = false

	private var produce: [Produce] {
		appCoordinator.produceData ?? []
	}

	private var tab: some View {
		tabView(for: selectedTab == .categories ? previousTab : selectedTab, produce: produce)
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

	var body: some View {
		ZStack {
			TabView(selection: $selectedTab) {
				Tab("Favourites", systemImage: "heart", value: .favourites) { tab }
				Tab("Months", systemImage: "calendar", value: .period(AnyPeriod(Months.currentPeriod))) { tab }
				Tab("Seasons", systemImage: "cloud.sun", value: .period(AnyPeriod(Seasons.currentPeriod))) { tab }
				Tab("Categories", systemImage: .settings, value: .categories) { tab }
					.popover(isPresented: $showCategoryMenu) {
						categoriesPopOverView
					}
				Tab(value: .search(AnyPeriod(Months.)), role: .search) {
					NavigationStack {
						tab
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

	private func tabView(for tab: MainTabScreen.Tabs, produce: [Produce]) -> AnyView {
		switch tab {
		case .favourites:
			AnyView(ProduceList(produce: produce, period: Months.april, parentTab: tab))
		case .period(let type):
			if type.is(Months.self) {
				AnyView(
					NavigationStack {
						PeriodTabView<Months>(
							produce: produce,
							selectedTab: tab,
							selectedCategory: $selectedCategory,
							selectedPeriod: Months.currentPeriod
						)
					}
					.toolbarBackground(.visible, for: .navigationBar)
					.toolbarBackground(Color.clear, for: .navigationBar)
				)
			} else if type.is(Seasons.self) {
				AnyView(
					NavigationStack {
						PeriodTabView<Seasons>(
							produce: produce,
							selectedTab: tab,
							selectedCategory: $selectedCategory,
							selectedPeriod: Seasons.currentPeriod
						)
					}
					.toolbarBackground(.visible, for: .navigationBar)
					.toolbarBackground(Color.clear, for: .navigationBar)
				)
			} else {
				AnyView(EmptyView())
			}
		case .categories:
			AnyView(EmptyView())
		case .search:
			AnyView(SearchView(produce: produce, selectedTab: selectedTab, selectedPeriod: $selectedPeriod, selectedCategory: $selectedCategory))
		default:
			AnyView(EmptyView())
		}
	}
}

@available(iOS 26, *)
#Preview {
	MainTabScreen()
		.environmentObject(previewCoordinator)
}
