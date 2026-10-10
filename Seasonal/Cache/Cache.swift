//
//  Cache.swift
//  Seasonal
//
//  Created by Clint Thomas on 23/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

final class Cache<Key: Hashable, Value> {

	private var storage: [Key: Value] = [:]

	func value(for key: Key, orInsert build: () -> Value) -> Value {
		if let cached = storage[key] {
			return cached
		}
		let newValue = build()
		storage[key] = newValue
		return newValue
	}

	func removeAll() {
		storage.removeAll()
	}
}
