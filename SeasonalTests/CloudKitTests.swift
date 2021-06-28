//
//  CloudKitTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 25/5/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import XCTest

import CloudKit
@testable import Seasonal

class CloudKitTests: XCTestCase {

	// Test private CloudKit, not sure how to test data in my public database
	// I cannot figure out how to get my data, or save data to CloudKit

//	func testPublicCLoudKitDataFetch() {
//		var record = [CKRecord]()
//
//		let container = CKContainer.default()
//
//		let mockContainer = MockCloudKit(container: container)
//
//		mockContainer.getData( dataFetched: { results in
//			print("IN?")
//			print(results)
//			record = results
//		})
//		XCTAssertEqual(record.count, 94)
//	}
}

class MockCloudKit: CKDatabaseProtocol {

	private let container: CKContainer

	init(container: CKContainer) {
		self.container = container
	}

	fileprivate var database: CKDatabase {
		return self.container.publicCloudDatabase
	}

	func perform(_ query: CKQuery, inZoneWith zoneID: CKRecordZone.ID?, completionHandler: @escaping ([CKRecord]?, Error?) -> Void) {
		self.database.perform(query, inZoneWith: zoneID, completionHandler: completionHandler)
	}

	func save(_ record: CKRecord, completionHandler: @escaping (CKRecord?, Error?) -> Void) {
		self.database.save(record, completionHandler: completionHandler)
	}

	func getData(dataFetched: @escaping([CKRecord]) -> Void) {
		let predicate = NSPredicate(value: true)
		let publicQuery = CKQuery(recordType: Constants.australianProduce, predicate: predicate)
		publicQuery.sortDescriptors = [NSSortDescriptor(key: Constants.id, ascending: true)]
		var publicData = [CKRecord]()

		_ = CKQueryOperation(query: publicQuery)

//		operation.recordFetchedBlock = { record in
//			print(record) 
//		}
//
//
//		operation.queryCompletionBlock = { cursor, error in
//			print("completion block")
//			print(cursor, error)
//		}

		perform(publicQuery, inZoneWith: .default) { results, error in
			dataFetched([CKRecord]())
			print("won't get in here :(")
			if let error = error {
				print(error.localizedDescription)
			} else {
				if results != nil && results!.count > 0 {
					publicData = results!
					dataFetched(publicData)
				}
			}
		}
	}
}
