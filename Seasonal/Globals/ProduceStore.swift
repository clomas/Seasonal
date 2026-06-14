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
	@Published private(set) var produce: [Int: Produce] = [:]
	@Published private(set) var allProduce: [Produce] = []

	private let cache = ProduceCache()

	// MARK: - Derived views

	var favourites: [Produce] {
		cache.favourites(from: allProduce)
	}

	func byPeriod<P: PeriodType>(_ period: P, query: String = "") -> [Produce] {
		let base = cache.byPeriod(period, from: allProduce)
		guard !query.isEmpty else { return base }
		return base.filter { $0.name?.localizedCaseInsensitiveContains(query) == true }
	}

	// MARK: - Toggle Likes

	func toggleLiked(for id: Int) {
		guard let item = produce[id] else { return }
		let updatedLiked = !item.liked

		produce[id] = Produce(
			id: item.id,
			name: item.name,
			category: item.category,
			imageName: item.imageName,
			description: item.description,
			months: item.months,
			seasons: item.seasons,
			liked: updatedLiked
		)

		cache.favourites(from: Array(produce.values))

		Task { await syncLikeToCloudKit(id: id, liked: updatedLiked) }
	}

	// MARK: - Fetch Produce

	func fetchFromCloudKit(for location: StateLocation) async -> Result<Void, CKError> {
        
        if let cachedProduce = fetchFromCache() {
            allProduce = cachedProduce
            produce = Dictionary(uniqueKeysWithValues: cachedProduce.map { ($0.id, $0) })
            return .success(())
        }

		switch await ProduceServicesManager.getDataFromCloudKit(for: location) {
		case let .success(produceList):
			produce = Dictionary(uniqueKeysWithValues: produceList.map { ($0.id, $0) })
			allProduce = produceList.sorted { ($0.name ?? "") < ($1.name ?? "") }

			cache.allProduce(from: produceList)

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
        let cached = cache.allProduce()
        
        return if !cached.isEmpty {
            cached
        } else {
            nil
        }
    }
}
#if DEBUG
@available(iOS 26, *)
extension ProduceStore {
	func loadMockData(_ data: [Produce]) {
		produce = Dictionary(uniqueKeysWithValues: data.map { ($0.id, $0) })
		allProduce = data
	}
}
#endif
