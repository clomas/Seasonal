//
//  ProduceStore.swift
//  Seasonal
//
//  Created by Clint Thomas on 31/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import CloudKit
import SwiftUI

@MainActor
@available(iOS 26, *)
final class ProduceStore: ObservableObject {

	private let cache = ProduceCache()
	private let diskCache = ProduceDiskCache()

	@Published private(set) var allProduce: [Produce] = []

	var favourites: [Produce] {
		cache.favourites(from: allProduce)
	}

	func byPeriod<P: PeriodType>(_ period: P) -> [Produce] {
		cache.byPeriod(period, from: allProduce)
	}

	func toggleLiked(for id: Int) {
		guard let index = allProduce.firstIndex(where: { $0.id == id }) else { return }
		let liked = !allProduce[index].liked
		allProduce[index] = allProduce[index].withLiked(liked)
		cache.invalidate()

		Task { await ProduceServicesManager.updateLike(id: id, liked: liked) }
	}

	func prepareForLocationChange() {
		cache.invalidate()
		diskCache.clear()
		allProduce = []
	}

	func fetchFromCloudKit(for location: StateLocation) async -> Result<Void, CKError> {
		if let cached = cache.cachedAllProduce(), !cached.isEmpty {
			allProduce = cached
			return .success(())
		}

		// With the base catalogue on disk, only liked state needs refreshing from CloudKit.
		if let baseProduce = diskCache.load(for: location) {
			return await apply(ProduceServicesManager.getLikesFromCloudKit(for: location, basedOn: baseProduce))
		}

		let result = await ProduceServicesManager.getDataFromCloudKit(for: location)
		if case let .success(produceList) = result {
			diskCache.save(produceList, for: location)
		}
		return apply(result)
	}

	private func apply(_ result: Result<[Produce], CKError>) -> Result<Void, CKError> {
		result.map { produceList in
			allProduce = produceList.sortedByName()
			cache.allProduce(from: produceList)
		}
	}
}

#if DEBUG
@available(iOS 26, *)
extension ProduceStore {
	func loadMockData(_ data: [Produce]) {
		allProduce = data
	}
}
#endif
