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

extension CKDatabase: CKDatabaseProtocol { }

enum CloudKitError: Error {
    case databaseError
    case castingError
}

class CloudKitDataService {

    static let instance = CloudKitDataService()
    var currentLocation: StateLocation = .noState
	let container = CKContainer.default()

    private func iCloudUserIDAsync(complete: @escaping (_ instance: CKRecord.ID?, _ error: NSError?) -> Void) {
        container.fetchUserRecordID { recordID, error in
            if error != nil {
                print(error!.localizedDescription)
                complete(nil, error as NSError?)
            } else {
                print("fetched ID \(String(describing: recordID?.recordName))")
                complete(recordID, nil)
            }
        }
    }

    // MARK: CloudKit Database

    func getData(for locationFound: StateLocation, dataFetched: @escaping([Produce]) -> Void) {
        currentLocation = locationFound
        let predicate = NSPredicate(value: true)
		let publicQuery = CKQuery(recordType: Constants.australianProduce, predicate: predicate)
        let privateQuery = CKQuery(recordType: Constants.australianProduce, predicate: predicate)
		publicQuery.sortDescriptors = [NSSortDescriptor(key: Constants.id, ascending: true)]
        privateQuery.sortDescriptors = [NSSortDescriptor(key: Constants.id, ascending: true)]
        var publicData = [CKRecord]()
        var privateData = [CKRecord]()

        CKContainer.default().publicCloudDatabase.perform(publicQuery, inZoneWith: .default) { [unowned self] results, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if results != nil && results!.count > 0 {
                    publicData = results!
                }
                CKContainer.default().privateCloudDatabase.perform(privateQuery, inZoneWith: .default) { [unowned self] results, error in
                    if let error = error {
                        dataFetched(addDataToArray(publicRecords: publicData, privateRecords: privateData))

                        print(error.localizedDescription)
                    } else {
                        if results != nil {
                            privateData = results!
                            dataFetched(addDataToArray(publicRecords: publicData, privateRecords: privateData))
                        }
                    }
                }
            }
        }
    }

    // MARK: Sort Data

    private func addDataToArray(publicRecords: [CKRecord], privateRecords: [CKRecord]) -> [Produce] {
        var produceArray = [Produce]()
		let likedArray = privateRecords.map { $0.object(forKey: Constants.id ) as? Int}

        for record in publicRecords {

			var id = 0
			var name = Constants.apple
            var imageName = Constants.apple
            var category = ViewDisplayed.ProduceCategory.fruit
            let description = ""
            var months = [Month]()
            var seasons = [Season]()
            var liked = false

			if let recordID = record.object(forKey: Constants.id) as? Int,
			   let nameRecord = record.object(forKey: Constants.name) as? String,
			   let categoryRecord = record.object(forKey: Constants.category) as? String,
               let monthsRecord = record.object(forKey: "months_\(currentLocation.rawValue)") as? String,
               let seasonsRecord = record.object(forKey: "seasons_\(currentLocation.rawValue)") as? String {
				id = recordID
                name = nameRecord
                imageName = nameRecord
                category = ViewDisplayed.ProduceCategory.asArray.filter {$0.asString == categoryRecord}[0]
                months = monthsRecord.createMonthArray()
                seasons = seasonsRecord.createSeasonArray()
            }

			if likedArray.contains(record.object(forKey: Constants.id) as? Int) {
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

        let localLikedData = LocalDataManager.loadAll(LikedProduce.self)
        if localLikedData.count > 0 {
            compareCoreDataToCloudKitData(locallyStoredData: localLikedData, produceArray: &produceArray)
        }
        return produceArray
    }

    // Update cloudKit with local data if there is a disparity
    // local data should always be accurate
    private func compareCoreDataToCloudKitData(locallyStoredData: [LikedProduce], produceArray: inout [Produce]) {
        let likedArray = produceArray.filter { $0.liked == true}

        for localLike in locallyStoredData {
            if likedArray.firstIndex(where: {$0.id == localLike.id}) == nil {
                if let index = produceArray.firstIndex(where: {$0.id == localLike.id}) {
                    produceArray[index].liked = true
                }
                CloudKitDataService.instance.saveLikeToPrivateDatabaseInCloudKit(id: localLike.id)
            }
        }
    }

    // MARK: Save

    func saveLikeToPrivateDatabaseInCloudKit(id: Int) {
        if FileManager.default.ubiquityIdentityToken != nil {
            let newPrivateRecordID = CKRecord.ID(recordName: "\(id)_")
			let newPrivateRecord = CKRecord(recordType: Constants.australianProduceLikes, recordID: newPrivateRecordID)
            newPrivateRecord.setValue(id, forKey: Constants.id)

			CKContainer.default().privateCloudDatabase.save(newPrivateRecord) { (record, error) in
                guard record != nil else {
                    print(error as Any)
                    return
                }
            }
        }
    }
}

// On creating the database I made some questionable decisions, I could have maybe handled it better.
// string matching is required to convert database data to useable app data.

extension String {

    // Parse Seasons
    func createSeasonArray() -> [Season] {
        var seasons = [Season]()

        if self.contains(Season.summer.shortName) {
            seasons.append(.summer)
        }
        if self.contains(Season.autumn.shortName) {
            seasons.append(.autumn)
        }
        if self.contains(Season.winter.shortName) {
            seasons.append(.winter)
        }
        if self.contains(Season.spring.shortName) {
            seasons.append(.spring)
        }
        return seasons
    }

	// Parse Months
    func createMonthArray() -> [Month] {
        var months = [Month]()
        var searchStartIndex = self.startIndex

        while searchStartIndex < self.endIndex,
              // find 1 in month string which indicates the produce is in season
              let range = self.range(of: "1", range: searchStartIndex..<self.endIndex),
			  !range.isEmpty {
            let index = distance(from: self.startIndex, to: range.lowerBound)

			// add 1 here for infiniteCollectionView offset
			if let month = Month.init(rawValue: index + 1) {
				months.append(month)
			}
            searchStartIndex = range.upperBound
        }
        return months
    }
}
