//
//  ProduceStore.swift
//  Seasonal
//
//  Created by Clint Thomas on 31/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI
import CloudKit

@MainActor
@available(iOS 26, *)
final class ProduceStore: ObservableObject {
	@Published private(set) var allProduce: [Produce] = []

	private let cache = ProduceCache()
	private let diskCache = ProduceDiskCache()

	// MARK: - Derived views

	var favourites: [Produce] {
		cache.favourites(from: allProduce)
	}

	/// Every produce matching the query, regardless of period — what the search tab shows.
	/// Empty query means no results rather than everything, so the screen opens on its
	/// prompt instead of the full catalogue.
	func search(_ query: String) -> [Produce] {
		cache.search(query, from: allProduce)
	}

	func byPeriod<P: PeriodType>(_ period: P, query: String = "") -> [Produce] {
		let base = cache.byPeriod(period, from: allProduce)
		guard !query.isEmpty else { return base }
		return base.filter { $0.name?.localizedCaseInsensitiveContains(query) == true }
	}

	// MARK: - Toggle Likes

	func toggleLiked(for id: Int) {
		guard let index = allProduce.firstIndex(where: { $0.id == id }) else { return }
		let item = allProduce[index]
		let updatedLiked = !item.liked

		allProduce[index] = Produce(
			id: item.id,
			name: item.name,
			category: item.category,
			imageName: item.imageName,
			description: item.description,
			months: item.months,
			seasons: item.seasons,
			liked: updatedLiked
		)

		// Drop the memoised derived lists so they recompute with the new
		// liked state on the next read.
		cache.invalidate()

		Task { await syncLikeToCloudKit(id: id, liked: updatedLiked) }
	}

	// MARK: - Fetch Produce

	/// Clears cached and published produce so the next `fetchFromCloudKit` ignores
	/// the (location-agnostic) cache and re-fetches for a newly chosen state.
	func prepareForLocationChange() {
		cache.invalidate()
		diskCache.clear()
		allProduce = []
	}

	func fetchFromCloudKit(for location: StateLocation) async -> Result<Void, CKError> {

        if let cachedProduce = fetchFromCache() {
            allProduce = cachedProduce
            return .success(())
        }

        // The base catalogue (name/category/months/seasons) only changes with an
        // app update, so once we have it on disk we skip the public CloudKit
        // query and only refresh liked state from the private database.
        if let baseProduce = diskCache.load(for: location) {
            switch await ProduceServicesManager.getLikesFromCloudKit(for: location, basedOn: baseProduce) {
            case let .success(produceList):
                allProduce = produceList.sorted { ($0.name ?? "") < ($1.name ?? "") }
                cache.allProduce(from: produceList)
                return .success(())
            case let .failure(error):
                return .failure(error)
            }
        }

		switch await ProduceServicesManager.getDataFromCloudKit(for: location) {
		case let .success(produceList):
			allProduce = produceList.sorted { ($0.name ?? "") < ($1.name ?? "") }

			cache.allProduce(from: produceList)
			diskCache.save(produceList, for: location)

			return .success(())
		case let .failure(error):
			return .failure(error)
		}
	}

	// MARK: - CloudKit Sync

	private func syncLikeToCloudKit(id: Int, liked: Bool) async {
		await ProduceServicesManager.updateLike(id: id, liked: liked)
	}
    
    private func fetchFromCache() -> [Produce]? {
        guard let cached = cache.cachedAllProduce(), !cached.isEmpty else { return nil }
        return cached
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
