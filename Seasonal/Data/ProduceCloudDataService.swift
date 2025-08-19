//
//  ProduceCloudDataService.swift
//  Seasonal
//
//  Created by Clint Thomas on 6/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import CloudKit

actor ProduceCloudDataService {

	private let cloudKitDataService: CloudKitDataService = CloudKitDataService()
	private let location: StateLocation

	init(location: StateLocation) {
		self.location = location
	}

		// MARK: CloudKit Database

	func getData(for locationFound: StateLocation) -> [ProduceModel] {
		var model: [ProduceModel] = []

		Task {
			await cloudKitDataService.setDatabase(type: .public)
			let publicRecords = await cloudKitDataService.fetchItems(recordType: Constants.australianProduce, queryKey: Constants.id)

			await cloudKitDataService.setDatabase(type: .private)
			let privateRecords = await cloudKitDataService.fetchItems(recordType: Constants.australianProduce, queryKey: Constants.id)
				//
			model = addDataToArray(publicRecords: publicRecords, privateRecords: privateRecords)
		}
		return model
	}

		// MARK: Save

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

	private func addDataToArray(publicRecords: [CKRecord], privateRecords: [CKRecord]) -> [ProduceModel] {
		var produceArray: [ProduceModel] = [ProduceModel]()
		let likedArray: [Int?] = privateRecords.map { $0.object(forKey: Constants.id ) as? Int}

		for record in publicRecords {
			var id: Int = 0
			var name: String = Constants.apple
			var imageName: String = Constants.apple
			var category: ViewDisplayed.ProduceCategory = ViewDisplayed.ProduceCategory.fruit
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
				category = ViewDisplayed.ProduceCategory.asArray.filter { $0.asString == categoryRecord }[0]
				months = monthsRecord.createMonthArray()
				seasons = seasonsRecord.createSeasonArray()
			}

			if likedArray.contains(record.object(forKey: Constants.id) as? Int) {
				liked = Bool(truncating: id as NSNumber)
			}

			let produce: ProduceModel = ProduceModel(id: id,
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
	private func compareCoreDataToCloudKitData(locallyStoredData: [LikedProduce], produceArray: inout [ProduceModel]) {
		let likedArray: [ProduceModel] = produceArray.filter { $0.liked == true}

		for prod in produceArray where prod.liked {
#if DEBUG
				// TODO: probably don't need this here
			print("Liked produce:", prod.id, prod.liked)
#endif
		}
		Task {
			await cloudKitDataService.setDatabase(type: .private)
		}

		for localLike in locallyStoredData where likedArray.firstIndex(where: {$0.id == localLike.id}) == nil {

			if let index: Array<Produce>.Index = produceArray.firstIndex(where: {$0.id == localLike.id}) {
				produceArray[index].liked = true
			}

			let result = saveLikeToPrivateDatabaseInCloudKit(id: localLike.id)
#if DEBUG
			if result == true {
				print(result, "Found disparity - added like record in CloudKit - id: \(localLike.id)")
			} else {
					// TODO: Handle error here
				print(result)
			}
#endif
		}
	}
}
