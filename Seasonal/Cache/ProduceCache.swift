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

	private let appVersion = Bundle.main.shortVersion ?? "0"

	private var cache = Cache<ProduceCacheKey, [Produce]>()

	init() {
		invalidateIfAppUpdated()
	}

	@discardableResult
	func allProduce(from produce: [Produce] = []) -> [Produce] {
		cache.value(for: .allProduce) { produce.sortedByName() }
	}

	/// Unlike `allProduce(from:)`, never writes an empty placeholder into the cache on a miss.
	func cachedAllProduce() -> [Produce]? {
		cache.peek(for: .allProduce)
	}

	@discardableResult
	func favourites(from produce: [Produce]) -> [Produce] {
		cache.value(for: .favourites) { produce.filter(\.liked).sortedByName() }
	}

	func byPeriod<P: PeriodType>(_ period: P, from produce: [Produce]) -> [Produce] {
		cache.value(for: period.cacheKey) { produce.filter(period.contains).sortedByName() }
	}

	func invalidate() {
		cache.removeAll()
	}

	private func invalidateIfAppUpdated() {
		guard GlobalSettings.produceCacheAppVersion != appVersion else { return }
		cache = Cache<ProduceCacheKey, [Produce]>()
		GlobalSettings.produceCacheAppVersion = appVersion
	}
}
