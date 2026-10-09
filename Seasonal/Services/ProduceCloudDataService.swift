//
//  ProduceCloudDataService.swift
//  Seasonal
//
//  Created by Clint Thomas on 6/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import CloudKit

@available(iOS 26, *)
struct ProduceCloudDataService: Sendable {

    private let cloudKitDataService = CloudKitDataService()
    private let mapper: ProduceRecordMapper
    private let localLikes: LocalLikes

    init(location: StateLocation, localLikes: LocalLikes = LocalLikes()) {
        mapper = ProduceRecordMapper(location: location)
        self.localLikes = localLikes
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

    /// Never fails: without the private database (e.g. no iCloud account) local likes still apply.
    func getLikes(basedOn baseProduce: [Produce]) async -> [Produce] {
        let privateRecords = (try? await fetch(.private, recordType: Constants.australianProduceLikes).get()) ?? []
        var produce = baseProduce.map { $0.withLiked(false) }
        applyLikes(from: privateRecords, to: &produce)
        return produce
    }

    func saveLike(id: Int) async {
        PendingUnlikes.remove(id)
        let record = likeRecord(id: id)
        record.setValue(id, forKey: Constants.id)
        try? await cloudKitDataService.saveItem(record, in: .private)
    }

    /// Stays pending until CloudKit confirms the delete, so a failure is retried on the next fetch.
    func deleteLike(id: Int) async {
        PendingUnlikes.insert(id)
        do {
            try await cloudKitDataService.deleteItem(likeRecord(id: id), in: .private)
            PendingUnlikes.remove(id)
        } catch {
            return
        }
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

    /// Local likes are the source of truth: ones CloudKit is missing are pushed up, and pending
    /// unlikes are retried rather than restored.
    private func applyLikes(from privateRecords: [CKRecord], to produce: inout [Produce]) {
        let pendingUnlikes = PendingUnlikes.ids
        let cloudLikedIDs = Set(privateRecords.compactMap { $0.object(forKey: Constants.id) as? Int })
            .subtracting(pendingUnlikes)
        let localLikedIDs = localLikes.ids
        let likedIDs = cloudLikedIDs.union(localLikedIDs)

        for index in produce.indices where likedIDs.contains(produce[index].id) {
            produce[index] = produce[index].withLiked(true)
        }

        let missingFromCloud = localLikedIDs.subtracting(cloudLikedIDs)
        Task {
            for id in missingFromCloud { await saveLike(id: id) }
            for id in pendingUnlikes.subtracting(localLikedIDs) { await deleteLike(id: id) }
        }
    }
}
