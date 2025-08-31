//
//  Produce.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import Foundation

struct ProduceOld: Identifiable {
	var id: Int
	var name: String
	var category: ViewDisplayed.ProduceCategory?
	var imageName: String
	var description: String
	var months: [MonthOld]
	var seasons: [SeasonsOld]
	var liked: Bool
}
