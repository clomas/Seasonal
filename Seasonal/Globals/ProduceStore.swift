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

	@ObservationIgnored private var favouriteSync: Task<Void, Never>?
	@ObservationIgnored private var loadedLocation: StateLocation?

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

	/// Syncs are chained so quick toggles reach CloudKit in order.
	@discardableResult
	func toggleFavourite(for id: Int) -> Task<Void, Never>? {
		guard let index = allProduce.firstIndex(where: { $0.id == id }) else { return nil }
		let isFavourite = !allProduce[index].isFavourite
		allProduce[index] = allProduce[index].withFavourite(isFavourite)
		cache.invalidate()

		let previousSync = favouriteSync
		let sync = Task {
			await previousSync?.value
			await service.updateFavourite(id: id, isFavourite: isFavourite)
		}
		favouriteSync = sync
		return sync
	}

	/// The current produce stays in place until the new location's arrives, so a failure leaves it untouched.
	func fetchFromCloudKit(for location: StateLocation) async -> Result<Void, CKError> {
		guard location != loadedLocation else { return .success(()) }

		let result: Result<[Produce], CKError>
		if let baseProduce = diskCache.load(for: location) {
			result = .success(await service.favourites(for: location, basedOn: baseProduce))
		} else {
			result = await service.produce(for: location)
			if case let .success(produceList) = result {
				diskCache.save(produceList, for: location)
			}
		}

		return result.map { produceList in
			allProduce = produceList.sortedByName()
			cache.invalidate()
			loadedLocation = location
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
