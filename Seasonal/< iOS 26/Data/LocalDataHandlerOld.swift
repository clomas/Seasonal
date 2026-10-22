//
//  LocalDataHandlerOld.swift
//  Seasonal
//
//  Created by Clint Thomas on 9/11/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import Foundation

/// Stores likes locally as Codable files; kept in sync with CloudKit. Failures are tolerated
/// rather than fatal: a like that can't be read or written is re-synced from CloudKit.
enum LocalDataHandlerOld {

	static func save<T: Encodable>(_ object: T, with fileName: String) {
		guard let data = try? JSONEncoder().encode(object) else { return }
		try? data.write(to: fileURL(fileName), options: .atomic)
	}

	/// Skips any file that can't be read or isn't a `T`, including one deleted mid-listing.
	static func loadAll<T: Decodable>(_ type: T.Type) -> [T] {
		let files = (try? FileManager.default.contentsOfDirectory(at: documentDirectory(), includingPropertiesForKeys: nil)) ?? []
		return files.compactMap { url in
			guard let data = try? Data(contentsOf: url) else { return nil }
			return try? JSONDecoder().decode(type, from: data)
		}
	}

	static func delete(_ fileName: String) {
		try? FileManager.default.removeItem(at: fileURL(fileName))
	}

	private static func documentDirectory() -> URL {
		FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
	}

	private static func fileURL(_ fileName: String) -> URL {
		documentDirectory().appendingPathComponent(fileName, isDirectory: false)
	}
}
