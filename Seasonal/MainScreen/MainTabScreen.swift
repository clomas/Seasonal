//
//  MainTabScreen.swift
//  Seasonal
//
//  Created by Clint Thomas on 30/6/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI
import TipKit

@available(iOS 26, *)
struct MainTabScreen: View {

	enum Tabs: Hashable {
		case favourites
		case period(AnyPeriod)
		case categories
		case search(AnyPeriod) // TODO: Make optional? to search faves?

		var title: String {
			return switch self {
			case .favourites:
				"Favourites"
			case .period(let period):
				if let months = period.cast(Months.self) {
					months.typeName
				} else if let seasons = period.cast(Seasons.self) {
					seasons.typeName
				} else {
					"Unknown"
				}
			case .categories:
				"Categories"
			case .search:
				"Search"
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
	@State private var selectedTab: Tabs = StoredSelectedTab.tab
	@State private var previousTab: Tabs = .favourites
	@State private var originalTabBeforeCategories: Tabs = .favourites
	@State private var showCategoryMenu: Bool = false

	@State private var selectedCategory: ProduceCategory = .all

	@State private var searchString: String = ""
	@State private var showAlert: Bool = false
	@State private var isSearching = false
	@State private var showTip: Bool = !GlobalSettings.swipeTipShown.swipe

	private var tip: SwipeOnboardingTip {
		if case .period(let period) = selectedTab {
			if period.is(Months.self) {
				return SwipeOnboardingTip(context: "months")
			} else if period.is(Seasons.self) {
				return SwipeOnboardingTip(context: "seasons")
			}
		}
		return SwipeOnboardingTip(context: "default")
	}

	private var produce: [Produce] {
		appCoordinator.produceStore.allProduce
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
					.tint(category == selectedCategory ? Colour.inSeason : .primary)
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
			Color.clear.frame(width: 1, height: 200)
			TabView(selection: $selectedTab) {
				Tab("Favourites", systemImage: "heart", value: .favourites) { tab }
				Tab("Months", systemImage: "calendar", value: .period(AnyPeriod(Months.currentPeriod))) { tab }
				Tab("Seasons", systemImage: "cloud.sun", value: .period(AnyPeriod(Seasons.currentPeriod))) { tab }
				Tab("Categories", systemImage: .settings, value: .categories) { tab }
					.popover(isPresented: $showCategoryMenu) {
						categoriesPopOverView
					}
				Tab(value: .search(AnyPeriod(Months.currentPeriod)), role: .search) {
					NavigationStack {
						tab
					}
				}
			}
			.tint(Colour.inSeason)
		}

		// This onChange triggers when the selectedTab changes.
		// It updates showCategoryMenu and previousTab accordingly.
		// WARNING: It sets selectedTab inside the block, which may immediately re-trigger this onChange, potentially causing a feedback loop or excessive updates.
		//		.onChange(of: selectedTab) { oldTab, newTab in
		//			switch newTab {
		//			case .categories:
		//				showCategoryMenu.toggle()
		//			case .search(let currentPeriod):
		//				let periodToSearch: AnyPeriod = {
		//					switch previousTab {
		//					case .period(let period): return period
		//					case .search(let period): return period
		//					default: return currentPeriod
		//					}
		//				}()
		//				if currentPeriod != periodToSearch {
		//					selectedTab = .search(periodToSearch)
		//					return
		//				}
		//				previousTab = newTab
		//				showCategoryMenu = false
		//			default:
		//				previousTab = newTab
		//				showCategoryMenu = false
		//
		//				try? Tips.resetDatastore()
		//				try? Tips.configure()
		//				showTip = true
		//			}
		//
		//			StoredSelectedTab.storeTab(newTab)
		//		}
		.onChange(of: selectedTab) { oldTab, newTab in
			guard oldTab != newTab else { return }

			switch newTab {
			case .categories:
				showCategoryMenu.toggle()

			case .search(let currentPeriod):
				let periodToSearch: AnyPeriod = {
					switch previousTab {
					case .period(let period): return period
					case .search(let period): return period
					default: return currentPeriod
					}
				}()

				if currentPeriod != periodToSearch {
					DispatchQueue.main.async {
						selectedTab = .search(periodToSearch)
					}
					return
				}

				previousTab = newTab
				showCategoryMenu = false

			default:
				previousTab = newTab
				showCategoryMenu = false

				try? Tips.resetDatastore()
				try? Tips.configure()
				showTip = true
			}

			StoredSelectedTab.storeTab(newTab)
		}
		.alert("Title", isPresented: $showAlert) {
			Text("Message")
			Button("OK", role: .cancel) { }
		}
		.overlay {
			if showTip {
				ZStack {
					Color.black.opacity(0.45)
						.ignoresSafeArea()
						.transition(.opacity)
					TipView(tip)
						.frame(maxWidth: 280)
						.padding()
						.transition(.opacity.combined(with: .scale))
				}
			}
		}
		.onAppear {
			if showTip {
				try? Tips.resetDatastore()
				try? Tips.configure()
			}
		}
		.task(id: showTip) {
			guard showTip else { return }
			try? await Task.sleep(for: .seconds(8))
			withAnimation(.easeInOut(duration: 0.5)) {
				showTip = false
				GlobalSettings.swipeTipShown = TipShown(swipe: true)
			}
		}
	}

	// MARK: Overlay helpers

	private func dimBackgroundOverlay() -> some View {
		Color.black.opacity(0.3)
			.ignoresSafeArea()
			.transition(.opacity)
			.zIndex(9)
	}

	private func tipViewOverlay() -> some View {
		TipView(tip)
			.transition(.opacity.combined(with: .scale))
			.zIndex(10)
			.task {
				try? await Task.sleep(for: .seconds(2))
				withAnimation(.easeInOut(duration: 0.5)) {
					showTip = false
					//					GlobalSettings.swipeTipShown.swipe = true
				}
			}
	}

	// MARK: Main tab logic

	private func tabView(for tab: MainTabScreen.Tabs, produce: [Produce]) -> AnyView {
		switch tab {
		case .favourites:
			return AnyView(
				NavigationView {
					ProduceList<NoPeriod>(
						selectedPeriod: .none,
						parentTab: selectedTab,
						selectedCategory: $selectedCategory,
						produce: appCoordinator.produceStore.favourites
					)
					.navigationTitle(tab.title)
					.navigationBarTitleDisplayMode(.large)
					.toolbarBackground(.hidden, for: .navigationBar)
					.environmentObject(appCoordinator)
				}
			)
		case .period(let type):
			if type.is(Months.self) {
				return periodTabView(periodType: Months.self, period: Months.currentPeriod, tab: tab)

			} else if type.is(Seasons.self) {
				return periodTabView(periodType: Seasons.self, period: Seasons.currentPeriod, tab: tab)

			}
		case .search(let period):
			if let months = period.cast(Months.self) {
				return searchTabView(with: months)

			} else if let seasons = period.cast(Seasons.self) {
				return searchTabView(with: seasons)

			}
		default:
			return AnyView(EmptyView())
		}
		return AnyView(EmptyView())
	}

	private func periodTabView<P: PeriodType>(periodType: P.Type, period: P, tab: MainTabScreen.Tabs) -> AnyView {
		AnyView(
			//			TransparentBackgroundNavigationStack {
			PeriodTabView<P>(
				selectedTab: tab,
				selectedCategory: $selectedCategory,
				selectedPeriod: period
			)
			//			}
		)
	}

	private func searchTabView<P: PeriodType>(with period: P) -> AnyView {
		AnyView(
			SearchTabView(
				produce: produce,
				selectedTab: previousTab,
				selectedPeriod: period,
				selectedCategory: $selectedCategory
			)
		)
	}
}

@available(iOS 26, *)
#Preview {
	MainTabScreen()
		.environmentObject(previewCoordinator)
}

