//
//  ProduceStore.swift
//  Seasonal
//
//  Created by Clint Thomas on 31/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

@MainActor
final class ProduceStore: ObservableObject {
	@Published private(set) var produce: [Int: Produce] = [:] 

	func toggleLiked(for id: Int) {
		guard var item: Produce = produce[id] else { return }

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

		updateCache(produce[id]!)
		syncToCloudKit(id: id, liked: updatedLiked)
	}

	private func updateCache(_ produce: Produce) {
			// write to your cache (e.g. UserDefaults, CoreData, file, etc.)
	}

	private func syncToCloudKit(id: Int, liked: Bool) {
			// CloudKit update call
	}
}
