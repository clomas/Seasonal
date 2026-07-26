	//
	//  Cache.swift
	//  Seasonal
	//
	//  Created by Clint Thomas on 23/8/2025.
	//  Copyright © 2025 Clint Thomas. All rights reserved.
	//

import Foundation

final class Cache<Key: Hashable, Value> {
	private var storage: [Key: Value] = [:]
	private var timestamps: [Key: Date] = [:]
	private let expiryDate: Date?

	init(expiryDate: Date? = nil) {
		self.expiryDate = expiryDate
	}

	func peek(for key: Key) -> Value? {
		storage[key]
	}

	func value(for key: Key, orInsert build: () -> Value) -> Value {
		if let cached = storage[key] {
			if let expiryDate = expiryDate, let insertionDate = timestamps[key] {
				if insertionDate >= expiryDate {
					storage[key] = nil
					timestamps[key] = nil
				} else {
					return cached
				}
			} else if expiryDate == nil {
				return cached
			}
		}
		let newValue = build()
		storage[key] = newValue
		timestamps[key] = Date()
		return newValue
	}

	func removeAll() {
		storage.removeAll()
		timestamps.removeAll()
	}
}
