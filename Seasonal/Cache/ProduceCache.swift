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
	func allProduce(from produce: [Produce] = []) -> [Produce] {
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

	func byPeriod<P: PeriodType>(_ period: P, from produce: [Produce]) -> [Produce] {
		cache.value(for: period.cacheKey) {
			produce
				.filter { period.contains($0) }
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

	/// Clears all memoised derived lists. Call after mutating the underlying
	/// produce (e.g. toggling a like) so `favourites`/`byPeriod` recompute.
	func invalidate() {
		cache.removeAll()
	}

	private func invalidateIfAppUpdated() {
		if GlobalSettings.produceCacheAppVersion != appVersion {
			cache = Cache<ProduceCacheKey, [Produce]>()
			GlobalSettings.produceCacheAppVersion = appVersion
		}
	}
}
