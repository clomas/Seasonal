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
import UIKit
import CloudKit

/// A protocol to allow mocking a CKDatabase.
protocol CKDatabaseProtocol {
	func perform(_ query: CKQuery, inZoneWith zoneID: CKRecordZone.ID?, completionHandler: @escaping ([CKRecord]?, Error?) -> Void)
	func save(_ record: CKRecord, completionHandler: @escaping (CKRecord?, Error?) -> Void)
}

class CloudKitDataServiceOld {
	private let container: CKContainer = CKContainer.default()
    var currentLocation: StateLocation = .noState

    // MARK: CloudKit Database

    func getData(for locationFound: StateLocation, dataFetched: @escaping(Result<[Produce], CloudKitError>) -> Void) {
        currentLocation = locationFound
		let predicate: NSPredicate = NSPredicate(value: true)
		let publicQuery: CKQuery = CKQuery(recordType: Constants.australianProduce, predicate: predicate)
		let privateQuery: CKQuery = CKQuery(recordType: Constants.australianProduceLikes, predicate: predicate)
		publicQuery.sortDescriptors = [NSSortDescriptor(key: Constants.id, ascending: true)]
        privateQuery.sortDescriptors = [NSSortDescriptor(key: Constants.id, ascending: true)]
        var publicData: [CKRecord] = [CKRecord]()

        CKContainer.default().publicCloudDatabase.perform(publicQuery, inZoneWith: .default) { [unowned self] results, error in
			if let error: Error = error {
				#if DEBUG
                print(error.localizedDescription)
				#endif
				dataFetched(.failure(.databaseError))
            } else {
				if let publicResults: [CKRecord] = results {
                    publicData = publicResults
                }
                CKContainer.default().privateCloudDatabase.perform(privateQuery, inZoneWith: .default) { [unowned self] results, error in
					if let error: Error = error {
						// continue if private error
						let privateData: [CKRecord] = [CKRecord]()
						dataFetched(.success(addDataToArray(publicRecords: publicData, privateRecords: privateData)))
						#if DEBUG
                        print(error.localizedDescription)
						#endif
                    } else {
                        if let privateData: [CKRecord] = results {
							dataFetched(.success(addDataToArray(publicRecords: publicData, privateRecords: privateData)))
                        }
                    }
                }
            }
        }
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
			   let monthsRecord: String = record.object(forKey: "months_\(currentLocation.rawValue)") as? String,
			   let seasonsRecord: String = record.object(forKey: "seasons_\(currentLocation.rawValue)") as? String {
				id = recordID
                name = nameRecord
                imageName = nameRecord
				category = ProduceCategory(rawValue: categoryRecord) ?? .fruit
                months = monthsRecord.createMonthArray()
                seasons = seasonsRecord.createSeasonArray()
            }

			if likedArray.contains(record.object(forKey: Constants.id) as? Int) {
				liked = Bool(truncating: id as NSNumber)
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

		for prod in produceArray where prod.liked {
			#if DEBUG
			print(prod.id, prod.liked)
			#endif
		}

		for localLike in locallyStoredData where likedArray.firstIndex(where: {$0.id == localLike.id}) == nil {

			if let index: Array<ProduceOld>.Index = produceArray.firstIndex(where: {$0.id == localLike.id}) {
				produceArray[index].liked = true
			}
			saveLikeToPrivateDatabaseInCloudKit(id: localLike.id) { (result: Result<Bool, CloudKitError>) in
				#if DEBUG
				if result == .success(true) {
					print(result, "added like record in CloudKit - id: \(localLike.id)")
				} else {
					print(result)
				}
				#endif
			}
		}
	}

    // MARK: Save

	func saveLikeToPrivateDatabaseInCloudKit(id: Int, result: @escaping(Result<Bool, CloudKitError>) -> Void) {

        if FileManager.default.ubiquityIdentityToken != nil {
			let newPrivateRecordID: CKRecord.ID = CKRecord.ID(recordName: "\(id)_")
			let newPrivateRecord: CKRecord = CKRecord(recordType: Constants.australianProduceLikes, recordID: newPrivateRecordID)
            newPrivateRecord.setValue(id, forKey: Constants.id)

			CKContainer.default().privateCloudDatabase.save(newPrivateRecord) { (_, error) in
				if error != nil {
					result(.failure(.likesError))
				} else {
					result(.success(true))
				}
            }
        }
    }

	func deleteRecordsInPrivateDatabase(id: Int, result: @escaping(Result<Bool, CloudKitError>) -> Void) {

		if FileManager.default.ubiquityIdentityToken != nil {
			let operation: CKModifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [CKRecord.ID(recordName: "\(id)_")])
			operation.savePolicy = .allKeys

			operation.modifyRecordsCompletionBlock = { _, _, error in
				if error != nil {
					result(.failure(.likesError))
				} else {
					result(.success(true))
				}
			}
			CKContainer.default().privateCloudDatabase.add(operation)
		}
	}
}
	// On creating the database I made some questionable decisions, I could have maybe handled it better.
	// string matching is required to convert database data to useable app data.
extension String {

		// Parse Seasons
	func createSeasonArrayOld() -> [SeasonsOld] {
		var seasons: [SeasonsOld] = [SeasonsOld]()

		if self.contains(SeasonsOld.summer.shortName) {
			seasons.append(.summer)
		}
		if self.contains(SeasonsOld.autumn.shortName) {
			seasons.append(.autumn)
		}
		if self.contains(SeasonsOld.winter.shortName) {
			seasons.append(.winter)
		}
		if self.contains(SeasonsOld.spring.shortName) {
			seasons.append(.spring)
		}
		return seasons
	}

	// Parse Months
	func createMonthArray() -> [Months] {
		var months: [Months] = [Months]()
		var searchStartIndex: String.Index = self.startIndex

		while searchStartIndex < self.endIndex,
			  // find 1 in month string which indicates the produce is in season
			  let range: Range<String.Index> = self.range(of: "1", range: searchStartIndex..<self.endIndex),
			  !range.isEmpty {
			let index: Int = distance(from: self.startIndex, to: range.lowerBound)

				// add 1 here for infiniteCollectionView offset
			if let month: Months = Months(rawValue: index + 1) {
				months.append(month)
			}
			searchStartIndex = range.upperBound
		}
		return months
	}
}
