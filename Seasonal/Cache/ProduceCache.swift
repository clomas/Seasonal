//
//  ProduceCache.swift
//  Seasonal
//
//  Created by Clint Thomas on 23/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import Foundation

@MainActor
final class ProduceCache {

	private let cache = Cache<ProduceCacheKey, [Produce]>()

	func favourites(from produce: [Produce]) -> [Produce] {
		cache.value(for: .favourites) { produce.filter(\.liked).sortedByName() }
	}

	func byPeriod<P: PeriodType>(_ period: P, from produce: [Produce]) -> [Produce] {
		cache.value(for: period.cacheKey) { produce.filter(period.contains).sortedByName() }
	}

	func invalidate() {
		cache.removeAll()
	}
}
