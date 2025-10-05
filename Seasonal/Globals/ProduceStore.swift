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
	private let cache = ProduceCache()

	lazy var allProduce: [Produce] = Array(produce.values)

	var favourites: [Produce] {
		cache.favourites(from: Array(produce.values))
	}

	func byPeriod<Period: PeriodType>(_ period: Period) -> [Produce] {
		switch period {
		case let month as Months: return cache.byMonth(month, from: Array(produce.values))
		case let season as Seasons: return cache.bySeason(season, from: Array(produce.values))
		default: return []
		}
	}

	func toggleLiked(for id: Int) {
		guard let item: Produce = produce[id] else { return }

		let updatedLiked: Bool = !item.liked

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

		updateCache(produce[id])
		syncToCloudKit(id: id, liked: updatedLiked)
	}

	func fetchFromCloudKit(for location: StateLocation) async -> Bool {
		do {
			let result = try await ProduceServicesManager.getDataFromCloudKit(for: location)
			switch result {
			case .success(let produceList):
				let dict = Dictionary(uniqueKeysWithValues: produceList.map { ($0.id, $0) })
				await MainActor.run { self.produce = dict }
				return true
			case .failure:
				return false
			}
		} catch {
			return false
		}
	}

	private func updateCache(_ produce: Produce?) {
			// write to your cache (e.g. UserDefaults, CoreData, file, etc.)
	}

	private func syncToCloudKit(id: Int, liked: Bool) {
			// CloudKit update call
	}
}
