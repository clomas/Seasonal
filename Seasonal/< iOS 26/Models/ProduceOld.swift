//
//  Produce.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import Foundation

struct Produce: Identifiable {

	var produce: ProduceModel

	var id: Int {
		produce.id
	}
	var name: String {
		produce.name
	}
	var imageName: String {
		produce.imageName
	}
	var description: String {
		produce.description
	}
	var liked: Bool {
		get {
			return produce.liked
		} set(liked) {
			produce.liked = liked
		}
	}

		// Commented out redundant properties now provided by protocol conformance
	var produceName: String {
		produce.name
	}
	var category: ViewDisplayed.ProduceCategory? {
		produce.category.toOld
	}
	var months: [MonthOld] {
		produce.months.toOld
	}
	var seasons: [SeasonsOld] {
		produce.seasons.toOld
	}
}
