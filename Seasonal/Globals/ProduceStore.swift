//
//  ProduceStore.swift
//  Seasonal
//
//  Created by Clint Thomas on 31/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

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

	func byPeriod<Period: PeriodType>(_ period: Period) -> [Produce] {
		switch period {
		case let month as Months:
			return cache.byMonth(month, from: allProduce)
		case let season as Seasons:
			return cache.bySeason(season, from: allProduce)
		default:
			return []
		}
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

	func fetchFromCloudKit(for location: StateLocation) async -> Bool {
		let cached = cache.allProduce(from: [])
		if !cached.isEmpty {
			allProduce = cached
			produce = Dictionary(uniqueKeysWithValues: cached.map { ($0.id, $0) })
			return true
		}

		do {
			let result = try await ProduceServicesManager.getDataFromCloudKit(for: location)
			switch result {
			case .success(let produceList):
				produce = Dictionary(uniqueKeysWithValues: produceList.map { ($0.id, $0) })
				allProduce = produceList.sorted { ($0.name ?? "") < ($1.name ?? "") }

				cache.allProduce(from: produceList)

				return true
			case .failure:
				return false
			}
		} catch {
			return false
		}
	}

	// MARK: - CloudKit Sync

	private func syncLikeToCloudKit(id: Int, liked: Bool) async {
		await ProduceServicesManager.updateLike(id: id, liked: liked)
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
