//
//  SeasonalTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 25/5/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//
// I'm new to testing, I'm not able to load CloudKit 

import XCTest
@testable import Seasonal

class SeasonalTests: XCTestCase {
//
//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

	var produceDataService = ProduceDataService()
	var produce = [Produce]()
	var likedArray: [Int] = [4, 3, 30, 91, 2]

	var testMonthData = [[ProduceModel]]()
	var testSeasonData = [Season: [ProduceModel]]()

	struct DummyPublicCKRecords {
		let id: Int?
		let nameRecord: String?
		let categoryRecord: String?
		let monthsRecord: String?
		let seasonsRecord: String?
	}

	struct DummyPrivateCKRecords {
		let id: Int?
	}

	func mimicCloudKitData() {

		var publicData = [DummyPublicCKRecords]()
		var privateData = [DummyPrivateCKRecords]()

		for index in 0...93 {

			let indexString = String(index)
			var category: String
			var months: String
			var seasons: String

			if index < 41 {
				category = "fruit"
				months = "110110110001"
				seasons = "sum-spr"
			} else if index < 75 {
				category = "vegetables"
				months = "000011110000"
				seasons = "win-aut"
			} else {
				category = "herbs"
				months = "110110111111"
				seasons = "sum-aut-spr"
			}

			publicData.append(DummyPublicCKRecords(id: index,
												  nameRecord: "Produce\(indexString)",
												  categoryRecord: category,
												  monthsRecord: months,
												  seasonsRecord: seasons))
		}

		for index in likedArray {
			privateData.append(DummyPrivateCKRecords(id: index))
			produceDataService.updateLike(id: index, liked: true)
		}

		produce = addDataToArray(publicRecords: publicData, privateRecords: privateData)
	}

	private func addDataToArray(publicRecords: [DummyPublicCKRecords], privateRecords: [DummyPrivateCKRecords]) -> [Produce] {
		var produceArray = [Produce]()
		let likedArray = privateRecords.map { $0.id }

		for record in publicRecords {

			var id = 0
			var name = Constants.apple
			var imageName = Constants.apple
			var category = ViewDisplayed.ProduceCategory.fruit
			let description = ""
			var months = [Month]()
			var seasons = [Season]()
			var liked = false

			if let recordID = record.id,
			   let nameRecord = record.nameRecord,
			   let categoryRecord = record.categoryRecord,
			   let monthsRecord = record.monthsRecord,
			   let seasonsRecord = record.seasonsRecord {
				id = recordID
				name = nameRecord
				imageName = nameRecord
				category = ViewDisplayed.ProduceCategory.asArray.filter {$0.asString == categoryRecord}[0]
				months = monthsRecord.createMonthArray()
				seasons = seasonsRecord.createSeasonArray()
			}

			if likedArray.contains(record.id) {
				liked = Bool(truncating: id as NSNumber)
			}
			let produce = Produce(id: id,
								  name: name,
								  category: category,
								  imageName: imageName,
								  description: description, // Not implemented yet
								  months: months,
								  seasons: seasons,
								  liked: liked)

			produceArray.append(produce)
		}
		return produceArray
	}

	func getAndSortData() {
		mimicCloudKitData()
	}

	func testMonthsCloudKitData() {
		mimicCloudKitData()
		testMonthData = produce.sortIntoMonths()
		XCTAssertEqual(testMonthData.count, 14)
	}

	func testSeasonsCloudKitData() {
		mimicCloudKitData()
		testSeasonData = produce.sortIntoSeasons()
		XCTAssertEqual(testSeasonData.count, 4)
	}

	func testMonthFilters() {
		mimicCloudKitData()
		testMonthData = produce.sortIntoMonths()
		let mainViewModel = MainViewModel(monthsProduce: testMonthData,
										  favouritesProduce: [ProduceModel](),
										  viewDisplayed: .months,
										  monthToDisplay: .december,
										  currentMonth: .december,
										  previousMonth: .november,
										  category: .all,
										  searchString: ""
		)
		print(testMonthData.count)
		var testProduce = mainViewModel.filter(by: "1", of: .fruit)
		XCTAssertEqual(testProduce[2].count, 41)
		testProduce = mainViewModel.filter(by: "", of: .vegetables)
		XCTAssertEqual(testProduce[6].count, 34)
		testProduce = mainViewModel.filter(by: "", of: .herbs)
		XCTAssertEqual(testProduce[12].count, 19)
		testProduce = mainViewModel.filter(by: "", of: .all)
		XCTAssertEqual(testProduce[7].count, 94)
	}

	func testSeasonsFilters() {
		mimicCloudKitData()
		testSeasonData = produce.sortIntoSeasons()
		let seasonsViewModel = SeasonsViewModel(produceData: testSeasonData, season: .summer, category: .all, searchString: "")
		print(testMonthData.count)
		var testProduce = seasonsViewModel.filter(by: .winter, matching: "2", of: .vegetables)
		XCTAssertEqual(testProduce.count, 4)
		testProduce = seasonsViewModel.filter(by: .autumn, matching: "produce", of: .herbs)
		XCTAssertEqual(testProduce.count, 19)
	}
}
