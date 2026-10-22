//
//  CloudKitDataHandler.swift
//  Seasonal
//
//  Created by Clint Thomas on 2/8/20.
//  Copyright © 2020 Clint Thomas. All rights reserved.
//
// many thanks -
// https://www.youtube.com/watch?v=2Y45vk7d_Bg
// https://swiftrocks.com/avoiding-callback-hell-in-swift

import Foundation
import CloudKit

enum CloudKitErrorOld: Error {
    case likesError
}

final class CloudKitDataServiceOld: Sendable {
	private let cloudKitDataService: CloudKitDataService = CloudKitDataService()

	// MARK: CloudKit Database

	func getData(for locationFound: StateLocation, dataFetched: @escaping @MainActor @Sendable (Result<[ProduceOld], Error>) -> Void) {
		Task {
			do {
				let publicRecords: [CKRecord] = try await cloudKitDataService.fetchItems(.public, recordType: ConstantsOld.australianProduce, queryKey: ConstantsOld.id)
				// continue if private error
				let privateRecords: [CKRecord] = (try? await cloudKitDataService.fetchItems(.private, recordType: ConstantsOld.australianProduceLikes, queryKey: ConstantsOld.id)) ?? []
				await dataFetched(.success(addDataToArray(publicRecords: publicRecords, privateRecords: privateRecords, location: locationFound)))
			} catch {
				#if DEBUG
				print(error.localizedDescription)
				#endif
				await dataFetched(.failure(error))
			}
		}
	}

	// MARK: Sort Data

	private func addDataToArray(publicRecords: [CKRecord], privateRecords: [CKRecord], location: StateLocation) -> [ProduceOld] {
		var produceArray: [ProduceOld] = [ProduceOld]()
		let likedArray: [Int?] = privateRecords.map { $0.object(forKey: ConstantsOld.id ) as? Int}

		for record in publicRecords {
			var id: Int = 0
			var name: String = ConstantsOld.apple
			var imageName: String = ConstantsOld.apple
			var category: ViewDisplayed.ProduceCategory = ViewDisplayed.ProduceCategory.fruit
			let description: String = ""
			var months: [MonthOld] = [MonthOld]()
			var seasons: [SeasonsOld] = [SeasonsOld]()
			var liked: Bool = false

			if let recordID: Int = record.object(forKey: ConstantsOld.id) as? Int,
			   let nameRecord: String = record.object(forKey: ConstantsOld.name) as? String,
			   let categoryRecord: String = record.object(forKey: ConstantsOld.category) as? String,
			   let monthsRecord: String = record.object(forKey: ProduceRecordKey.months(for: location)) as? String {
				id = recordID
				name = nameRecord
				imageName = nameRecord
				category = ViewDisplayed.ProduceCategory.fromString(categoryRecord)
				months = monthsRecord.createMonthArrayOld()

				let seasonsKey = ProduceRecordKey.seasons(for: location)
				if let seasonsRecord = record.object(forKey: seasonsKey) as? String {
					seasons = seasonsRecord.createSeasonArrayOld()
				}
			}

			if likedArray.contains(record.object(forKey: ConstantsOld.id) as? Int) {
				liked = Bool(truncating: id as NSNumber)
			}

			let produce: ProduceOld = ProduceOld(id: id,
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

		let localLikedData: [LikedProduceOld] = LocalDataHandlerOld.loadAll(LikedProduceOld.self)
		if !localLikedData.isEmpty {
			compareCoreDataToCloudKitData(locallyStoredData: localLikedData, produceArray: &produceArray)
		}
		return produceArray
	}

	// Update cloudKit with local data if there is a disparity
	// local data should always be accurate
	private func compareCoreDataToCloudKitData(locallyStoredData: [LikedProduceOld], produceArray: inout [ProduceOld]) {
		let likedArray: [ProduceOld] = produceArray.filter { $0.liked == true}

		for localLike in locallyStoredData where likedArray.firstIndex(where: {$0.id == localLike.id}) == nil {
			let id: Int = localLike.id

			if let index: Array<ProduceOld>.Index = produceArray.firstIndex(where: {$0.id == id}) {
				produceArray[index].liked = true
			}
			saveLikeToPrivateDatabaseInCloudKit(id: id) { (result: Result<Bool, CloudKitErrorOld>) in
			#if DEBUG
				if result == .success(true) {
					print(result, "added like record in CloudKit - id: \(id)")
				}
			#endif
			}
		}
	}

	// MARK: Save

	func saveLikeToPrivateDatabaseInCloudKit(id: Int, result: @escaping @MainActor @Sendable (Result<Bool, CloudKitErrorOld>) -> Void) {
		Task {
			do {
				try await cloudKitDataService.saveItem(likeRecord(id: id), in: .private)
				await result(.success(true))
			} catch {
				await result(.failure(.likesError))
			}
		}
	}

	func deleteRecordsInPrivateDatabase(id: Int, result: @escaping @MainActor @Sendable (Result<Bool, CloudKitErrorOld>) -> Void) {
		Task {
			do {
				try await cloudKitDataService.deleteItem(likeRecord(id: id), in: .private)
				await result(.success(true))
			} catch {
				await result(.failure(.likesError))
			}
		}
	}

	private func likeRecord(id: Int) -> CKRecord {
		let record: CKRecord = CKRecord(recordType: ConstantsOld.australianProduceLikes, recordID: CKRecord.ID(recordName: ProduceRecordKey.favouriteRecordName(for: id)))
		record.setValue(id, forKey: ConstantsOld.id)
		return record
	}
}
// On creating the database I made some questionable decisions, I could have maybe handled it better.
// string matching is required to convert database data to useable app data.
extension String {

	func createSeasonArrayOld() -> [SeasonsOld] {
		var seasons: [SeasonsOld] = [SeasonsOld]()

		if self.contains(SeasonsOld.summer.shortName) { seasons.append(.summer) }
		if self.contains(SeasonsOld.autumn.shortName) { seasons.append(.autumn) }
		if self.contains(SeasonsOld.winter.shortName) { seasons.append(.winter) }
		if self.contains(SeasonsOld.spring.shortName) { seasons.append(.spring) }
		return seasons
	}

	func createMonthArrayOld() -> [MonthOld] {
		var months: [MonthOld] = [MonthOld]()
		var searchStartIndex: String.Index = self.startIndex

		while searchStartIndex < self.endIndex,
			  // find 1 in month string which indicates the produce is in season
			  let range: Range<String.Index> = self.range(of: "1", range: searchStartIndex..<self.endIndex),
			  !range.isEmpty {
			let index: Int = distance(from: self.startIndex, to: range.lowerBound)

				// add 1 here for infiniteCollectionView offset
			if let month: MonthOld = MonthOld(rawValue: index + 1) {
				months.append(month)
			}
			searchStartIndex = range.upperBound
		}
		return months
	}
}
