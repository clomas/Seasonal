//
//  ProduceCloudDataService.swift
//  Seasonal
//
//  Created by Clint Thomas on 6/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import CloudKit

@available(iOS 26, *)
actor ProduceCloudDataService {

	private let cloudKitDataService: CloudKitDataService = CloudKitDataService()
	private let location: StateLocation

	init(location: StateLocation) {
		self.location = location
	}

	// MARK: CloudKit Database

	func getData(for locationFound: StateLocation) async -> Result<[Produce], Error> {
		var publicRecords: [CKRecord] = []
		var privateRecords: [CKRecord] = []
		var fetchError: Error? = nil

		await withTaskGroup(of: (CloudKitDataService.DatabaseType, Result<[CKRecord], Error>).self) { group in
			group.addTask {
				await self.cloudKitDataService.setDatabase(type: .public)
				let recordsResult = await self.cloudKitDataService.fetchItems(.public, recordType: Constants.australianProduce, queryKey: Constants.id)
				return (.public, recordsResult)
			}
			group.addTask {
				await self.cloudKitDataService.setDatabase(type: .private)
				let recordsResult = await self.cloudKitDataService.fetchItems(.private, recordType: Constants.australianProduceLikes, queryKey: Constants.id)
				return (.private, recordsResult)
			}
			for await (type, result) in group {
				switch (type, result) {
				case (.public, .success(let records)):
					publicRecords = records
				case (.private, .success(let records)):
					privateRecords = records
				case (_, .failure(let error)):
					fetchError = error
				}
			}
		}
		if let error = fetchError {
			return .failure(error)
		}
		let produce = addDataToArray(publicRecords: publicRecords, privateRecords: privateRecords)
		return .success(produce)
	}

	// MARK: Save

	@discardableResult
	func saveLikeToPrivateDatabaseInCloudKit(id: Int) -> Bool {
		var success: Bool = false

		let record = recordWithID(id)
		record.setValue(id, forKey: Constants.id)

		Task {
			await cloudKitDataService.setDatabase(type: .private)
			switch await cloudKitDataService.saveItem(record) {
			case .success(_):
				success = true
			default:
				success = false
			}
		}
		return success
	}

	// MARK: Delete

	@discardableResult
	func deleteRecordsInPrivateDatabase(id: Int) -> Bool {
		var success: Bool = false

		let record = recordWithID(id)

		Task {
			await cloudKitDataService.setDatabase(type: .private)
			switch await cloudKitDataService.deleteItem(record) {
			case .success(_):
				success = true
			default:
				success = false
			}
		}
		return success
	}

	private func recordWithID(_ id: Int) -> CKRecord {
		CKRecord(
			recordType: Constants.australianProduceLikes,
			recordID: CKRecord.ID(recordName: "\(id)_")
		)
	}

	// MARK: Sort Data

	private func addDataToArray(publicRecords: [CKRecord], privateRecords: [CKRecord]) -> [Produce] {
		var produceArray: [Produce] = [Produce]()
		let likedArray: [Int?] = privateRecords.map { $0.object(forKey: Constants.id ) as? Int}

		for record in publicRecords {
			var id: Int = 0
			var name: String = Constants.apple
			var imageName: String = Constants.apple
			var category: ProduceCategory = ProduceCategory.fruit
			let description: String = ""
			var months: [Months] = [Months]()
			var seasons: [Seasons] = [Seasons]()
			var liked: Bool = false

			if let recordID: Int = record.object(forKey: Constants.id) as? Int,
			   let nameRecord: String = record.object(forKey: Constants.name) as? String,
			   let categoryRecord: String = record.object(forKey: Constants.category) as? String,
			   let monthsRecord: String = record.object(forKey: "months_\(location.rawValue)") as? String,
			   let seasonsRecord: String = record.object(forKey: "seasons_\(location.rawValue)") as? String {
				id = recordID
				name = nameRecord
				imageName = nameRecord
				category = ProduceCategory(rawValue: categoryRecord) ?? .fruit
				months = monthsRecord.createMonthArray()
				seasons = seasonsRecord.createSeasonArray()
			}

			if let recordIdValue = record.object(forKey: Constants.id) {

				let recordIdInt: Int?

				if let intValue = recordIdValue as? Int {
					recordIdInt = intValue

				} else if let stringValue = recordIdValue as? String, let intValue = Int(stringValue) {
					recordIdInt = intValue

				} else {
					recordIdInt = nil

				}

				if let recordIdInt, likedArray.contains(recordIdInt) {
					liked = true
				}
			}

			let produce: Produce = Produce(id: id,
													 name: name,
													 category: category,
													 imageName: imageName,
													 description: description, // Not implemented yet
													 months: months,
													 seasons: seasons,
													 liked: liked
			)
			produceArray.append(produce)
		}

		let localLikedData: [LikedProduce] = LocalDataHandler.loadAll(LikedProduce.self)
		if !localLikedData.isEmpty {
			compareCoreDataToCloudKitData(locallyStoredData: localLikedData, produceArray: &produceArray)
		}
		return produceArray
	}

	// Update cloudKit with local data if there is a disparity
	// local data should always be accurate
	private func compareCoreDataToCloudKitData(locallyStoredData: [LikedProduce], produceArray: inout [Produce]) {
		let likedArray: [Produce] = produceArray.filter { $0.liked == true}

		Task {
			await cloudKitDataService.setDatabase(type: .private)
		}

		for localLike in locallyStoredData where likedArray.firstIndex(where: {$0.id == localLike.id}) == nil {

			if let index: Array<ProduceOld>.Index = produceArray.firstIndex(where: {$0.id == localLike.id}) {
				produceArray[index].liked = true
			}

			let result = saveLikeToPrivateDatabaseInCloudKit(id: localLike.id)
#if DEBUG
			if result == true {
				print(result, "Found disparity - added like record in CloudKit - id: \(localLike.id)")
			}
#endif
		}
	}
}

// On creating the database I made some questionable decisions, I could have maybe handled it better.
// string matching is required to convert database data to useable app data.
extension String {

	// Parse Seasons
	func createSeasonArray() -> [Seasons] {
		var seasons: [Seasons] = [Seasons]()

		if self.contains(Seasons.summer.shortName) {
			seasons.append(.summer)
		}
		if self.contains(Seasons.autumn.shortName) {
			seasons.append(.autumn)
		}
		if self.contains(Seasons.winter.shortName) {
			seasons.append(.winter)
		}
		if self.contains(Seasons.spring.shortName) {
			seasons.append(.spring)
		}
		return seasons
	}

}

