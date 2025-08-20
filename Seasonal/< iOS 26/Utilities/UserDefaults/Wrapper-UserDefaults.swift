//
//  UserDefaults.swift
//  Seasonal
//
//  Created by Clint Thomas on 25/5/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//
// very good - https://stackoverflow.com/a/61131521/6440209

import Foundation

@propertyWrapper

struct UserDefault<T: Codable> {
	let key: String
	let defaultValue: T

	init(_ key: String, defaultValue: T) {
		self.key = key
		self.defaultValue = defaultValue
	}

	var wrappedValue: T {
		get {
			if let data: Data = UserDefaults.standard.object(forKey: key) as? Data,
			   let user: T = try? JSONDecoder().decode(T.self, from: data) {
				return user
			}
			return defaultValue
		}
		set {
			if let encoded: Data = try? JSONEncoder().encode(newValue) {
				UserDefaults.standard.set(encoded, forKey: key)
			}
		}
	}
}
