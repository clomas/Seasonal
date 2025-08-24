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

	@discardableResult
	func favourites(from produce: [Produce]) -> [Produce] {
		cache.value(for: .favourites) {
			produce.filter { $0.liked == true }
		}
	}

	// TODO: These aint sorted by alphabet
	@discardableResult
	func byMonth(_ month: Months, from produce: [Produce]) -> [Produce] {
		cache.value(for: .month(month)) {
			produce.filter { $0.months?.contains(month) == true }
		}
	}

	@discardableResult
	func bySeason(_ season: Seasons, from produce: [Produce]) -> [Produce] {
		cache.value(for: .season(season)) {
			produce.filter { $0.seasons?.contains(season) == true }
		}
	}

	@discardableResult
	func search(_ query: String, from produce: [Produce]) -> [Produce] {
		cache.value(for: .search(query)) {
			produce.filter { query.isEmpty == false && $0.name?.localizedCaseInsensitiveContains(query) == true }
		}
	}
}
