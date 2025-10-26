//
//  ProduceCache.swift
//  Seasonal
//
//  Created by Clint Thomas on 23/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import Foundation

@MainActor
final class ProduceCache: ObservableObject {
	private var cache = Cache<ProduceCacheKey, [Produce]>()
	private let appVersion: String

	init() {
		appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
		invalidateIfAppUpdated()
	}

	@discardableResult
	func allProduce(from produce: [Produce]) -> [Produce] {
		cache.value(for: .allProduce) {
			produce.sorted { ($0.name ?? "") < ($1.name ?? "") }
		}
	}

	@discardableResult
	func favourites(from produce: [Produce]) -> [Produce] {
		cache.value(for: .favourites) {
			produce
				.filter { $0.liked == true }
				.sorted { ($0.name ?? "") < ($1.name ?? "") }
		}
	}

	func byMonth(_ month: Months, from produce: [Produce]) -> [Produce] {
		cache.value(for: .month(month)) {
			produce
				.filter { $0.months?.contains(month) == true }
				.sorted { ($0.name ?? "") < ($1.name ?? "") }
		}
	}

	func bySeason(_ season: Seasons, from produce: [Produce]) -> [Produce] {
		cache.value(for: .season(season)) {
			produce
				.filter { $0.seasons?.contains(season) == true }
				.sorted { ($0.name ?? "") < ($1.name ?? "") }
		}
	}

	func search(_ query: String, from produce: [Produce]) -> [Produce] {
		cache.value(for: .search(query)) {
			produce
				.filter { query.isEmpty == false && $0.name?.localizedCaseInsensitiveContains(query) == true }
				.sorted { ($0.name ?? "") < ($1.name ?? "") }
		}
	}

	private func invalidateIfAppUpdated() {
		if GlobalSettings.produceCacheAppVersion != appVersion {
			cache = Cache<ProduceCacheKey, [Produce]>()
			GlobalSettings.produceCacheAppVersion = appVersion
		}
	}
}
