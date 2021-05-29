////
////  _OldTestCode.swift
////  Seasonal
////
////  Created by Clint Thomas on 25/5/21.
////  Copyright © 2021 Clint Thomas. All rights reserved.
////
//
//import Foundation
//
//
////
////  CloudKitTest.swift
////  SeasonalTests
////
////  Created by Clint Thomas on 20/5/21.
////  Copyright © 2021 Clint Thomas. All rights reserved.
////
////https://crunchybagel.com/simulating-cloudkit-errors
////https://www.hackingwithswift.com/forums/swift/how-to-unit-test-cloudkit-core-data/753
//
//import XCTest
//import CloudKit
//@testable import Seasonal
//
//class MockCloudKit: CKDatabaseProtocol {
//
//	private let container: CKContainer
//
//	init(container: CKContainer) {
//		self.container = container
//	}
//
//	fileprivate var database: CKDatabase {
//		return self.container.publicCloudDatabase
//	}
//
//
//	func add(_ operation: CKDatabaseOperation) {
//
//	}
//
//	func delete(withRecordID recordID: CKRecord.ID, completionHandler: @escaping (CKRecord.ID?, Error?) -> Void) {
//
//	}
//
//	func fetch(withRecordID recordID: CKRecord.ID, completionHandler: @escaping (CKRecord?, Error?) -> Void) {
//
//	}
//
//	func perform(_ query: CKQuery, inZoneWith zoneID: CKRecordZone.ID?, completionHandler: @escaping ([CKRecord]?, Error?) -> Void) {
//		self.database.perform(query, inZoneWith: zoneID, completionHandler: completionHandler)
//	}
//
//	func save(_ record: CKRecord, completionHandler: @escaping (CKRecord?, Error?) -> Void) {
//
//	}
//
//	func getData(dataFetched: @escaping([CKRecord]) -> (Void)) {
//
//		let predicate = NSPredicate(value: true)
//		let publicQuery = CKQuery(recordType: Constants.australianProduce, predicate: predicate)
//		//	let privateQuery = CKQuery(recordType: Constants.australianProduce, predicate: predicate)
//		publicQuery.sortDescriptors = [NSSortDescriptor(key: Constants.id, ascending: true)]
//		//privateQuery.sortDescriptors = [NSSortDescriptor(key: Constants.id, ascending: true)]
//		var publicData = [CKRecord]()
//		//	var privateData = [CKRecord]()
//
//		perform(publicQuery, inZoneWith: .default) { results, error in
//			dataFetched([CKRecord]())
//			print("------------- IN?")
//			if let error = error {
//				print("-----!!!----------!!!------- \(error.localizedDescription)")
//			} else {
//				if results != nil && results!.count > 0 {
//					publicData = results!
//					dataFetched(publicData)
//				}
//				//				mockContainer.perform(privateQuery, inZoneWith: .default) { results, error in
//				//					if let error = error {
//				//						dataFetched(privateData)
//				//
//				//						print(error.localizedDescription)
//				//					} else {
//				//						if results != nil {
//				//							privateData = results!
//				//							dataFetched(privateData)
//				//						}
//				//					}
//				//				}
//			}
//		}
//	}
//}
//
//class CloudKitTest: XCTestCase {
//
//	func saveLikeToPrivateDatabaseInCloudKit(id: Int) {
//
//		let newPrivateRecordID = CKRecord.ID(recordName: "\(id)_")
//		let newPrivateRecord = CKRecord(recordType: Constants.australianProduceLikes, recordID: newPrivateRecordID)
//		newPrivateRecord.setValue(id, forKey: Constants.id)
//
//		let container = CKContainer.default()
//
//		let mockContainer = MockCloudKit(container: container)
//
//		mockContainer.save(newPrivateRecord) { (record, error) in
//			print("save record attempt")
//			print(record)
//			guard record != nil else {
//				print(error as Any)
//				print("nah")
//				return
//			}
//		}
//		//		}
//	}
//
//	func getData2(for locationFound: StateLocation, dataFetched: @escaping([CKRecord]) -> (Void)) {
//
//		let predicate = NSPredicate(value: true)
//		let publicQuery = CKQuery(recordType: Constants.australianProduce, predicate: predicate)
//		//	let privateQuery = CKQuery(recordType: Constants.australianProduce, predicate: predicate)
//		publicQuery.sortDescriptors = [NSSortDescriptor(key: Constants.id, ascending: true)]
//		//privateQuery.sortDescriptors = [NSSortDescriptor(key: Constants.id, ascending: true)]
//		var publicData = [CKRecord]()
//		//	var privateData = [CKRecord]()
//
//		let container = CKContainer.default()
//
//		let mockContainer = MockCloudKit(container: container)
//
//		mockContainer.perform(publicQuery, inZoneWith: .default) { results, error in
//			print("------------- IN?")
//			if let error = error {
//				print("-----!!!----------!!!------- \(error.localizedDescription)")
//			} else {
//				if results != nil && results!.count > 0 {
//					publicData = results!
//					dataFetched(publicData)
//				}
//				//				mockContainer.perform(privateQuery, inZoneWith: .default) { results, error in
//				//					if let error = error {
//				//						dataFetched(privateData)
//				//
//				//						print(error.localizedDescription)
//				//					} else {
//				//						if results != nil {
//				//							privateData = results!
//				//							dataFetched(privateData)
//				//						}
//				//					}
//				//				}
//			}
//		}
//	}
//
//	private func addDataToArray(publicRecords: [CKRecord], privateRecords: [CKRecord]) -> [Produce] {
//		var produceArray = [Produce]()
//		let likedArray = privateRecords.map { $0.object(forKey: Constants.id ) as? Int}
//
//		for record in publicRecords {
//
//			var name = Constants.apple
//			var imageName = Constants.apple
//			var category = ViewDisplayed.ProduceCategory.fruit
//			let description = ""
//			var months = [Month]()
//			var seasons = [Season]()
//			var liked = false
//
//			if let nameRecord = record.object(forKey: Constants.name) as? String,
//			   let categoryRecord = record.object(forKey: Constants.category) as? String,
//			   let monthsRecord = record.object(forKey: "months_wa") as? String,
//			   let seasonsRecord = record.object(forKey: "seasons_wa") as? String {
//				name = nameRecord
//				imageName = nameRecord
//				category = ViewDisplayed.ProduceCategory.asArray.filter{$0.asString == categoryRecord}[0]
//				months = monthsRecord.createMonthArray()
//				seasons = seasonsRecord.createSeasonArray()
//			}
//
//			if likedArray.contains(record.object(forKey: Constants.id) as? Int) {
//				liked = Bool(truncating: (record.object(forKey: Constants.id) as! Int) as NSNumber)
//			}
//
//			let produce = Produce(id: record.object(forKey: Constants.id) as! Int,
//								  name: name,
//								  category: category,
//								  imageName: imageName,
//								  description: description, // Not implemented yet
//								  months: months,
//								  seasons: seasons,
//								  liked: liked)
//
//			produceArray.append(produce)
//		}
//		return produceArray
//	}
//
//
//
//	// Test private CloudKit, not sure how to test data in my public database
//	func testPrivateCLoudKit() {
//		var record = [CKRecord]()
//
//		let container = CKContainer.default()
//
//		let mockContainer = MockCloudKit(container: container)
//
//		mockContainer.getData( dataFetched: { results in
//			print("IN?")
//			print(results)
//		})
//		//saveLikeToPrivateDatabaseInCloudKit(id: 4)
//		//		getData(for: .westernAustralia, dataFetched: { publicRecords in
//		//			print("closure in")
//		//			record = publicRecords
//		//		})
//
//		XCTAssertEqual(record.count, 94)
//	}
//}
//
//
////
////  SeasonalUTests.swift
////  SeasonalTests
////
////  Created by Clint Thomas on 23/5/21.
////  Copyright © 2021 Clint Thomas. All rights reserved.
////
//
//import XCTest
//@testable import Seasonal
//
//class SeasonalUITests: XCTestCase {
//
//	var app: XCUIApplication!
//
//	override func setUpWithError() throws {
//		continueAfterFailure = false
//
//		app = XCUIApplication()
//		//	app.launchArguments = ["enable-testing"]
//		app.launch()
//	}
//
//	func testSomeLogic() {
//		let storyboard = UIStoryboard(name: "MainViewController", bundle: nil)
//		let viewController:UIViewController = storyboard.instantiateViewController(withIdentifier: "loginViewController") as! _MainViewController
//		print(viewController.classForCoder)
//		print(type(of: viewController))
//		let _ = viewController.view
//		//test on viewController
//	}
//
//	func testAppHas4Tabs() throws {
//
//
//
//		print("")
//		//
//		//		let element = UIViewController(nibName: "MainViewController", bundle: .main)
//		//		let predicate = NSPredicate(format: "exists == true")
//		//		let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
//		//
//		//		let result = XCTWaiter().wait(for: [expectation], timeout: 1)
//		//		XCTAssertEqual(.completed, result)
//
//		//		print(app.collectionViews.cells.count)
//		//		XCTAssertEqual(app.collectionViews.cells.count, 4, "There should be 4 tabs in the app.")
//		//		app
//
//		//		let myButton = app.buttons["info"]
//		//		XCTAssertTrue(myButton.waitForExistence(timeout: 10))
//
//		//	myButton.tap()
//	}
//}
