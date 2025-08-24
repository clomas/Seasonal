//
//  CloudKitDataService.swift
//  Seasonal
//
//  Created by Clint Thomas on 1/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import Foundation
import CloudKit

enum CloudKitError: Error {
	case databaseError
	case invalidID
	case likesError
	case noToken
}

actor CloudKitDataService: ObservableObject {

	enum DatabaseType {
		case `private`
		case `public`
	}

	private let container: CKContainer = .default()

	private var databaseType: DatabaseType = .public
	private var hasUbiquityIdentityToken: Bool {
		FileManager.default.ubiquityIdentityToken != nil
	}

	func setDatabase(type: DatabaseType) {
		databaseType = type
	}

	/// Fetches all records for the given recordType and queryKey,
	/// returning all results including both successes and failures.
	func fetchItems(_ databaseType: DatabaseType, recordType: String, queryKey: String) async -> Result<[CKRecord], Error> {
		let database = databaseType == .private ? container.privateCloudDatabase : container.publicCloudDatabase

		let predicate = NSPredicate(value: true)
		let query = CKQuery(recordType: recordType, predicate: predicate)
		query.sortDescriptors = [NSSortDescriptor(key: queryKey, ascending: true)]

		do {
			let (matchResults, _) = try await database.records(matching: query)
			var records: [CKRecord] = []

			for (_, result) in matchResults {
				switch result {
				case .success(let record):
					records.append(record)
				case .failure(let error):
					return .failure(error)
				}
			}
			return .success(records)
		} catch {
			return .failure(error)
		}
	}

	func saveItem(_ record: CKRecord) async -> Result<CKRecord, Error> {
		guard hasUbiquityIdentityToken else { return .failure(CloudKitError.noToken) }
		let database = databaseType == .private
			? container.privateCloudDatabase
			: container.publicCloudDatabase

		do {
			let record = try await database.save(record)
			return .success(record)
		} catch {
			return .failure(CloudKitError.likesError)
		}
	}

	func deleteItem(_ record: CKRecord) async -> Result<CKRecord.ID, Error> {
		guard hasUbiquityIdentityToken else { return .failure(CloudKitError.noToken) }
		let database = databaseType == .private
			? container.privateCloudDatabase
			: container.publicCloudDatabase

		do {
			let recordID = try await database.deleteRecord(withID: record.recordID)
			return .success(recordID)
		} catch {
			return .failure(CloudKitError.likesError)
		}
	}
}

