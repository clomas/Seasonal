//
//  ProduceRecordKey.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/2/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

enum ProduceRecordKey {

	// MARK: - Record types

	static let australianProduce = "Australian_Produce"
	// The raw value predates the rename; changing it would orphan existing CloudKit records.
	static let australianProduceFavourites = "Australian_Produce_Likes"

	// MARK: - Record fields

	static let id = "id"
	static let name = "name"
	static let category = "category"

	static func months(for location: StateLocation) -> String {
		"months_\(location.rawValue)"
	}

	static func seasons(for location: StateLocation) -> String {
		"seasons_\(location.rawValue)"
	}

	// MARK: - Record names

	static func favouriteRecordName(for id: Int) -> String {
		"\(id)_"
	}
}
