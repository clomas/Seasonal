//
//  Produce.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

// TODO: Rename
struct ProduceModel: Identifiable {
	let id: Int
	let name: String
	let category: ProduceCategory
	let imageName: String
	let description: String // Not implemented yet
	let months: [Months]
	let seasons: [Seasons]
	var liked: Bool
}
