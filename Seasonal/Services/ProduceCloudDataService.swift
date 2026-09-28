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

    private let cloudKitDataService = CloudKitDataService()
    private let mapper: ProduceRecordMapper

    init(location: StateLocation) {
        mapper = ProduceRecordMapper(location: location)
    }

    /// Fails only when a fetch errored and nothing at all came back.
    func getData() async -> Result<[Produce], CKError> {
        async let publicFetch = fetch(.public, recordType: Constants.australianProduce)
        async let privateFetch = fetch(.private, recordType: Constants.australianProduceLikes)
        let results = await [publicFetch, privateFetch]

        let publicRecords = (try? results[0].get()) ?? []
        let privateRecords = (try? results[1].get()) ?? []
        let firstError = results.lazy.compactMap { result -> CKError? in
            if case let .failure(error) = result { error } else { nil }
        }.first

        if let firstError, publicRecords.isEmpty, privateRecords.isEmpty {
            return .failure(firstError)
        }

        var produce = mapper.produce(from: publicRecords)
        applyLikes(from: privateRecords, to: &produce)
        return .success(produce)
    }

    /// Refreshes liked state only, for when the base catalogue is already cached.
    func getLikes(basedOn baseProduce: [Produce]) async -> Result<[Produce], CKError> {
        await fetch(.private, recordType: Constants.australianProduceLikes).map { privateRecords in
            var produce = baseProduce.map { $0.withLiked(false) }
            applyLikes(from: privateRecords, to: &produce)
            return produce
        }
    }

    func saveLike(id: Int) {
        let record = likeRecord(id: id)
        record.setValue(id, forKey: Constants.id)
        Task { await cloudKitDataService.saveItem(record, in: .private) }
    }

    func deleteLike(id: Int) {
        let record = likeRecord(id: id)
        Task { await cloudKitDataService.deleteItem(record, in: .private) }
    }

    private func fetch(_ database: CloudKitDataService.DatabaseType, recordType: String) async -> Result<[CKRecord], CKError> {
        do {
            return .success(try await cloudKitDataService.fetchItems(database, recordType: recordType, queryKey: Constants.id))
        } catch {
            return .failure(error as? CKError ?? CKError(.internalError))
        }
    }

    private func likeRecord(id: Int) -> CKRecord {
        CKRecord(recordType: Constants.australianProduceLikes, recordID: CKRecord.ID(recordName: "\(id)_"))
    }

    /// Local likes are the source of truth: they're applied even when CloudKit lags or is
    /// unavailable, and any that CloudKit is missing are pushed back up.
    private func applyLikes(from privateRecords: [CKRecord], to produce: inout [Produce]) {
        let cloudLikedIDs = Set(privateRecords.compactMap { $0.object(forKey: Constants.id) as? Int })
        let localLikedIDs = Set(LocalDataHandler.loadAll(LikedProduce.self).map(\.id))
        let likedIDs = cloudLikedIDs.union(localLikedIDs)

        for index in produce.indices where likedIDs.contains(produce[index].id) {
            produce[index] = produce[index].withLiked(true)
        }

        for id in localLikedIDs.subtracting(cloudLikedIDs) {
            saveLike(id: id)
        }
    }
}
