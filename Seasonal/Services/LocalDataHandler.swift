//
//  LocalDataManager.swift
//  Seasonal
//
//  Created by Clint Thomas on 9/11/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//
// Using FileManager as well as user defaults so I have two references
// of how to store local data.

import Foundation

// Store like data locally as well as CloudKit
// Will be kept in sync with CloudKit
public class LocalDataHandler {

    // Get document directory
    static fileprivate func getDocumentDirectory () -> URL {
		if let url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Unable to access document directory")
        }
    }

    // Save any kind of codable object
    static func save <T: Encodable> (_ object: T, with fileName: String) {
        let url: URL = getDocumentDirectory().appendingPathComponent(fileName, isDirectory: false)
		let encoder: JSONEncoder = JSONEncoder()

        do {
			let data: Data = try encoder.encode(object)

            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }

            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    // Load any kind of codable objects
    static func load <T: Decodable> (_ fileName: String, with type: T.Type) -> T {
        let url: URL = getDocumentDirectory().appendingPathComponent(fileName, isDirectory: false)
        if !FileManager.default.fileExists(atPath: url.path) {
            fatalError("File not found at path \(url.path)")
        }

		if let data: Data = FileManager.default.contents(atPath: url.path) {
            do {
				let model: T = try JSONDecoder().decode(type, from: data)
                return model
            } catch {
                fatalError(error.localizedDescription)
            }
        } else {
            fatalError("data unavailable at path \(url.path)")
        }
    }

    // Load data from a file
    static func loadData (_ fileName: String) -> Foundation.Data? {
        let url: URL = getDocumentDirectory().appendingPathComponent(fileName, isDirectory: false)
        if !FileManager.default.fileExists(atPath: url.path) {
            fatalError("File not found at path \(url.path)")
        }
		if let data: Data = FileManager.default.contents(atPath: url.path) {
            return data
        } else {
            fatalError("data unavailable at path \(url.path)")
        }
    }

    // Load all files from a directory
    static func loadAll <T: Decodable> (_ type: T.Type) -> [T] {
        do {
			let filePaths: [String] = try FileManager.default.contentsOfDirectory(atPath: getDocumentDirectory().path)

			var modelObjects: [T] = [T]()

            for filePath in filePaths {
                modelObjects.append(load(filePath, with: type))
            }
            return modelObjects
        } catch {
            fatalError("could not load any files")
        }
    }

    // Delete a file
    static func delete (_ fileName: String) {
        let url: URL = getDocumentDirectory().appendingPathComponent(fileName, isDirectory: false)

        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
