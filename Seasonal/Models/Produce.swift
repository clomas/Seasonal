//
//  Produce.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

struct Produce: Identifiable, Sendable, Codable {
	let id: Int
	let name: String?
	let category: ProduceCategory?
	let imageName: String?
	let description: String?
	let months: [Months]?
	let seasons: [Seasons]?
	let isFavourite: Bool
}

extension Produce {
	func withFavourite(_ isFavourite: Bool) -> Produce {
		Produce(
			id: id,
			name: name,
			category: category,
			imageName: imageName,
			description: description,
			months: months,
			seasons: seasons,
			isFavourite: isFavourite
		)
	}
}

extension Array where Element == Produce {
	func sortedByName() -> [Produce] {
		sorted { ($0.name ?? "") < ($1.name ?? "") }
	}
}
