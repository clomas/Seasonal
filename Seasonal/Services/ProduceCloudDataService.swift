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

    func getData(for locationFound: StateLocation) async -> Result<[Produce], CKError> {
        var publicRecords: [CKRecord] = []
        var privateRecords: [CKRecord] = []
        var fetchErrors: [Error] = []

        await withTaskGroup(of: (CloudKitDataService.DatabaseType, Result<[CKRecord], Error>).self) { group in
            group.addTask {
                await self.cloudKitDataService.setDatabase(type: .public)
                do {
                    let records = try await self.cloudKitDataService.fetchItems(.public, recordType: Constants.australianProduce, queryKey: Constants.id)
                    return (.public, .success(records))
                } catch {
                    return (.public, .failure(error))
                }
            }
            group.addTask {
                await self.cloudKitDataService.setDatabase(type: .private)
                do {
                    let records = try await self.cloudKitDataService.fetchItems(.private, recordType: Constants.australianProduceLikes, queryKey: Constants.id)
                    return (.private, .success(records))
                } catch {
                    return (.private, .failure(error))
                }
            }
            for await (type, result) in group {
                switch (type, result) {
                case (.public, .success(let records)):
                    publicRecords = records
                case (.private, .success(let records)):
                    privateRecords = records
                case (_, .failure(let error)):
                    fetchErrors.append(error)
                }
            }
        }
        if !fetchErrors.isEmpty && publicRecords.isEmpty && privateRecords.isEmpty {
            return .failure(fetchErrors.first as? CKError ?? CKError(.internalError))
        }
        let produce = addDataToArray(publicRecords: publicRecords, privateRecords: privateRecords)
        return .success(produce)
    }

    // MARK: Save

    @discardableResult
    func saveLikeToPrivateDatabaseInCloudKit(id: Int) -> Bool {
        let record = recordWithID(id)
        record.setValue(id, forKey: Constants.id)

        Task {
            await cloudKitDataService.setDatabase(type: .private)
            
            do {
                return try await cloudKitDataService.saveItem(record) != nil
            } catch {
                return false
            }
        }
        return false
    }

    // MARK: Delete

    @discardableResult
    func deleteRecordsInPrivateDatabase(id: Int) -> Bool {
        let record = recordWithID(id)

        Task {
            await cloudKitDataService.setDatabase(type: .private)
            do {
                return try await cloudKitDataService.deleteItem(record) != nil
            } catch {
                return false
            }
        }
        return false
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
                switch categoryRecord {
                case "vegetables":
                    category = .vegetables
                case "herbs":
                    category = .herbs
                default:
                    category = .fruit
                }
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

            let produce: Produce = Produce(
                id: id,
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

    // Local data is the source of truth for likes: apply it to the loaded produce
    // (so a like persists even when the CloudKit private fetch lags or iCloud is
    // unavailable) and back-fill CloudKit for any local like it is missing.
    private func compareCoreDataToCloudKitData(locallyStoredData: [LikedProduce], produceArray: inout [Produce]) {
        // ids already marked liked from the CloudKit private database
        let cloudLikedIDs: Set<Int> = Set(produceArray.filter { $0.liked == true }.map { $0.id })
        let locallyLikedIDs: Set<Int> = Set(locallyStoredData.map { $0.id })

        Task {
            await cloudKitDataService.setDatabase(type: .private)
        }

        // Apply local likes that CloudKit didn't already return.
        for index in produceArray.indices
        where locallyLikedIDs.contains(produceArray[index].id) && !cloudLikedIDs.contains(produceArray[index].id) {
            let item: Produce = produceArray[index]
            produceArray[index] = Produce(
                id: item.id,
                name: item.name,
                category: item.category,
                imageName: item.imageName,
                description: item.description,
                months: item.months,
                seasons: item.seasons,
                liked: true
            )
        }

        // Push any local like missing from the private database up to CloudKit.
        for localLike in locallyStoredData where !cloudLikedIDs.contains(localLike.id) {
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

    func createMonthArray() -> [Months] {
        var months: [Months] = [Months]()
        var searchStartIndex: String.Index = self.startIndex

        while searchStartIndex < self.endIndex,
              // find 1 in month string which indicates the produce is in season
              let range: Range<String.Index> = self.range(of: "1", range: searchStartIndex..<self.endIndex),
              !range.isEmpty {
            let index: Int = distance(from: self.startIndex, to: range.lowerBound)

            // Add 1 - January rawValue == 1
            if let month: Months = Months(rawValue: index + 1) {
                months.append(month)
            }
            searchStartIndex = range.upperBound
        }
        return months
    }
}
