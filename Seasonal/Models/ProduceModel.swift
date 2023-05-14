//
//  Produce.swift
//  Seasonal
//
//  Created by Clint Thomas on 21/11/20.
//  Copyright © 2020 Clint Thomas. All rights reserved.
//

//
// struct Produce {
//	var id: Int
//	var produceName: String
//	var imageName: String
//	var category: ViewDisplayed.ProduceCategory
//	var months: [Month]
//	var seasons: [Season]
//	var liked: Bool
// }

import Foundation

struct Produce {

	var produce: ProduceModel

	init(produce: ProduceModel) {
		self.produce = produce
	}
	var id: Int {
		produce.id
	}
	var produceName: String {
		produce.name
	}
	var imageName: String {
		produce.imageName
	}
	var category: ViewDisplayed.ProduceCategory? {
		produce.category
	}
	var months: [Month] {
		produce.months
	}
	var seasons: [Season] {
		produce.seasons
	}
	var liked: Bool {
		get {
			return produce.liked
		} set(liked) {
			produce.liked = liked
		}
	}
}

struct ProduceModel {
    let id: Int
    let name: String
    let category: ViewDisplayed.ProduceCategory
    let imageName: String
    let description: String // Not implemented yet
    let months: [Month]
    let seasons: [Season]
    var liked: Bool
}

extension ProduceModel {
	var produceId: Int {
		return id
	}
}
