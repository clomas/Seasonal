//
//  Produce.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

enum ProduceCacheKey: Hashable {
	case allProduce
	case favourites
	case month(Months)
	case season(Seasons)
	case search(String)
}

struct Produce: Identifiable, Sendable, Codable {
	let id: Int
	let name: String?
	let category: ProduceCategory?
	let imageName: String?
	let description: String?
	let months: [Months]?
	let seasons: [Seasons]?
	let liked: Bool
}
