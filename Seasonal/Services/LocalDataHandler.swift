//
//  LocalDataHandler.swift
//  Seasonal
//
//  Created by Clint Thomas on 9/11/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import Foundation

/// Stores likes locally as Codable files; kept in sync with CloudKit.
enum LocalDataHandler {

	static func save<T: Encodable>(_ object: T, with fileName: String) {
		let url = fileURL(fileName)
		do {
			let data = try JSONEncoder().encode(object)
			if FileManager.default.fileExists(atPath: url.path) {
				try FileManager.default.removeItem(at: url)
			}
			FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
		} catch {
			fatalError(error.localizedDescription)
		}
	}

	static func load<T: Decodable>(_ fileName: String, with type: T.Type) -> T {
		let url = fileURL(fileName)
		guard let data = FileManager.default.contents(atPath: url.path) else {
			fatalError("Data unavailable at path \(url.path)")
		}
		do {
			return try JSONDecoder().decode(type, from: data)
		} catch {
			fatalError(error.localizedDescription)
		}
	}

	static func loadAll<T: Decodable>(_ type: T.Type) -> [T] {
		do {
			return try FileManager.default
				.contentsOfDirectory(atPath: documentDirectory().path)
				.map { load($0, with: type) }
		} catch {
			fatalError("Could not load any files")
		}
	}

	static func delete(_ fileName: String) {
		let url = fileURL(fileName)
		guard FileManager.default.fileExists(atPath: url.path) else { return }
		do {
			try FileManager.default.removeItem(at: url)
		} catch {
			fatalError(error.localizedDescription)
		}
	}

	private static func documentDirectory() -> URL {
		guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
			fatalError("Unable to access document directory")
		}
		return url
	}

	private static func fileURL(_ fileName: String) -> URL {
		documentDirectory().appendingPathComponent(fileName, isDirectory: false)
	}
}
