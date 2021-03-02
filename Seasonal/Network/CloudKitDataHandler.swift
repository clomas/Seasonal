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

// TODO: use core data
// TODO: Rename to cloudkitdataservice.


enum CloudKitError: Error {
    case databaseError
    case castingError
}

class CloudKitDataHandler {
    
    static let instance = CloudKitDataHandler()
    private let publicDatabase = CKContainer.default().publicCloudDatabase
    private let privateDatabase = CKContainer.default().privateCloudDatabase
    var currentLocation: StateLocation = .noState

    private func iCloudUserIDAsync(complete: @escaping (_ instance: CKRecord.ID?, _ error: NSError?) -> ()) {
        let container = CKContainer.default()
        container.fetchUserRecordID() {
            recordID, error in
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

    func getData(locationFound: StateLocation, dataFetched: @escaping([Produce]) -> (Void)) {
        currentLocation = locationFound
        let predicate = NSPredicate(value: true)
        let publicQuery = CKQuery(recordType: AUSTRALIAN_PRODUCE, predicate: predicate)
        let privateQuery = CKQuery(recordType: AUSTRALIAN_PRODUCE, predicate: predicate)
        publicQuery.sortDescriptors = [NSSortDescriptor(key: ID, ascending: true)]
        privateQuery.sortDescriptors = [NSSortDescriptor(key: ID, ascending: true)]
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
        let likedArray = privateRecords.map { $0.object(forKey: ID ) as? Int}

        for record in publicRecords {

            var name = APPLE
            var imageName = APPLE
            var category = ViewDisplayed.ProduceFilter.fruit
            let description = ""
            var months = [Month]()
            var seasons = [Season]()
            var liked = false

            if let nameRecord = record.object(forKey: NAME) as? String,
               let categoryRecord = record.object(forKey: CATEGORY) as? String,
               let monthsRecord = record.object(forKey: "months_\(currentLocation.rawValue)") as? String,
               let seasonsRecord = record.object(forKey: "seasons_\(currentLocation.rawValue)") as? String {
                name = nameRecord
                imageName = nameRecord
                category = ViewDisplayed.ProduceFilter.asArray.filter{$0.asString == categoryRecord}[0]
                months = monthsRecord.createMonthArray()
                seasons = seasonsRecord.createSeasonArray()
            }

            if likedArray.contains(record.object(forKey: ID) as? Int) {
                liked = Bool(truncating: (record.object(forKey: ID) as! Int) as NSNumber)
            }

            let produce = Produce(id: record.object(forKey: ID) as! Int,
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

    // Update cloudkit with local data if there is a disparity
    // local data should always be accurate
    private func compareCoreDataToCloudKitData(locallyStoredData: [LikedProduce], produceArray: inout [Produce]) {
        let likedArr = produceArray.filter{ $0.liked == true}

        for localLike in locallyStoredData {
            if likedArr.firstIndex(where: {$0.id == localLike.id}) == nil {
                if let index = produceArray.firstIndex(where: {$0.id == localLike.id}) {
                    produceArray[index].liked = true
                }
                CloudKitDataHandler.instance.saveLikeToPrivateDatabaseInCloudKit(id: localLike.id)
            }
        }
    }

    // MARK: Save

    func saveLikeToPrivateDatabaseInCloudKit(id: Int) {
        if FileManager.default.ubiquityIdentityToken != nil {
            let newPrivateRecordID = CKRecord.ID(recordName: "\(id)_")
            let newPrivateRecord = CKRecord(recordType: AUSTRALIAN_PRODUCE_LIKES, recordID: newPrivateRecordID)
            newPrivateRecord.setValue(id, forKey: ID)

            privateDatabase.save(newPrivateRecord) { (record, error) in
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

    // Parse seasons
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

    func createMonthArray() -> [Month] {
        var months = [Month]()
        var searchStartIndex = self.startIndex

        while searchStartIndex < self.endIndex,
              // find 1 in month string which indicates the produce is in season
              let range = self.range(of: "1", range: searchStartIndex..<self.endIndex),
              !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            months.append(Month(rawValue: index)!)
            searchStartIndex = range.upperBound
        }
        return months
    }
}
