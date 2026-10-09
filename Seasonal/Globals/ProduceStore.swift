//
//  ProduceStore.swift
//  Seasonal
//
//  Created by Clint Thomas on 31/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import CloudKit
import Observation

@MainActor
@Observable
@available(iOS 26, *)
final class ProduceStore {

	private let cache = ProduceCache()
	private let service: any ProduceProviding
	private let diskCache: any ProduceDiskCaching

	private(set) var allProduce: [Produce] = []

	@ObservationIgnored private var likeSync: Task<Void, Never>?

	var favourites: [Produce] {
		cache.favourites(from: allProduce)
	}

	init(service: any ProduceProviding = ProduceServicesManager(), diskCache: any ProduceDiskCaching = ProduceDiskCache()) {
		self.service = service
		self.diskCache = diskCache
	}

	func byPeriod<P: PeriodType>(_ period: P) -> [Produce] {
		cache.byPeriod(period, from: allProduce)
	}

	/// Syncs are chained so a quick like then unlike reaches CloudKit in order.
	@discardableResult
	func toggleLiked(for id: Int) -> Task<Void, Never>? {
		guard let index = allProduce.firstIndex(where: { $0.id == id }) else { return nil }
		let liked = !allProduce[index].liked
		allProduce[index] = allProduce[index].withLiked(liked)
		cache.invalidate()

		let previousSync = likeSync
		let sync = Task {
			await previousSync?.value
			await service.updateLike(id: id, liked: liked)
		}
		likeSync = sync
		return sync
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

		if let baseProduce = diskCache.load(for: location) {
			return await apply(.success(service.likes(for: location, basedOn: baseProduce)))
		}

		let result = await service.produce(for: location)
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
