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

	func getData(for locationFound: StateLocation) async -> [Produce] {
		var publicRecords: [CKRecord] = []
		var privateRecords: [CKRecord] = []

		do {
			try await withThrowingTaskGroup(of: (CloudKitDataService.DatabaseType, [CKRecord]).self) { [weak self] group in
				guard let self: ProduceCloudDataService else { return }

				group.addTask {
					await self.cloudKitDataService.setDatabase(type: .public)
					let records = await self.cloudKitDataService.fetchItems(recordType: Constants.australianProduce, queryKey: Constants.id)
					return (.public, records)
				}
				group.addTask {
					await self.cloudKitDataService.setDatabase(type: .private)
					let records = await self.cloudKitDataService.fetchItems(recordType: Constants.australianProduceLikes, queryKey: Constants.id)
					return (.private, records)
				}
				for try await (type, records) in group {
					switch type {
					case .public:
						publicRecords = records
					case .private:
						privateRecords = records
					}
				}
			}
			return addDataToArray(publicRecords: publicRecords, privateRecords: privateRecords)
		} catch {
			return []
		}
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

		for prod in produceArray where prod.liked == true {
#if DEBUG
			print("Liked produce in CloudKit: \(String(describing: prod.id)), \(String(describing: prod.liked))")
#endif
		}
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
			} else {

				print(result)
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

