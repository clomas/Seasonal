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
    private let localFavourites: LocalFavourites
    private let pendingChanges: PendingFavouriteChanges

    init(location: StateLocation, localFavourites: LocalFavourites, pendingChanges: PendingFavouriteChanges) {
        mapper = ProduceRecordMapper(location: location)
        self.localFavourites = localFavourites
        self.pendingChanges = pendingChanges
    }

    /// Fails only when a fetch errored and nothing at all came back.
    func getData() async -> Result<[Produce], CKError> {
        async let publicFetch = fetch(.public, recordType: ProduceRecordKey.australianProduce)
        async let privateFetch = fetch(.private, recordType: ProduceRecordKey.australianProduceFavourites)
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
        syncFavourites(with: results[1], in: &produce)
        return .success(produce)
    }

    /// Never fails: without the private database (e.g. no iCloud account) local favourites still apply.
    func getFavourites(basedOn baseProduce: [Produce]) async -> [Produce] {
        let privateFetch = await fetch(.private, recordType: ProduceRecordKey.australianProduceFavourites)
        var produce = baseProduce.map { $0.withFavourite(false) }
        syncFavourites(with: privateFetch, in: &produce)
        return produce
    }

    /// Stays pending until CloudKit confirms it, so a failure is retried on the next fetch.
    func updateFavourite(id: Int, isFavourite: Bool) async {
        pendingChanges.record(id, isFavourite: isFavourite)
        await push(id, isFavourite: isFavourite)
    }

    private func fetch(_ database: CloudKitDataService.DatabaseType, recordType: String) async -> Result<[CKRecord], CKError> {
        do {
            return .success(try await cloudKitDataService.fetchItems(database, recordType: recordType, queryKey: ProduceRecordKey.id))
        } catch {
            return .failure(error as? CKError ?? CKError(.internalError))
        }
    }

    private func favouriteRecord(id: Int) -> CKRecord {
        CKRecord(recordType: ProduceRecordKey.australianProduceFavourites, recordID: CKRecord.ID(recordName: ProduceRecordKey.favouriteRecordName(for: id)))
    }

    private func syncFavourites(with privateFetch: Result<[CKRecord], CKError>, in produce: inout [Produce]) {
        let cloudIDs = try? Set(privateFetch.get().compactMap { $0.object(forKey: ProduceRecordKey.id) as? Int })
        let sync = FavouriteSync(
            cloudIDs: cloudIDs,
            localIDs: localFavourites.ids,
            pending: pendingChanges.changes,
            hasSynced: pendingChanges.hasSynced
        )

        if cloudIDs != nil {
            for id in sync.adopted { pendingChanges.record(id, isFavourite: true) }
            pendingChanges.markSynced()
            for (id, isFavourite) in sync.confirmed { pendingChanges.clear(id, ifStill: isFavourite) }
            localFavourites.replace(with: sync.favouriteIDs)
        }

        for index in produce.indices where sync.favouriteIDs.contains(produce[index].id) {
            produce[index] = produce[index].withFavourite(true)
        }

        Task {
            for id in sync.toSave { await push(id, isFavourite: true) }
            for id in sync.toDelete { await push(id, isFavourite: false) }
        }
    }

    private func push(_ id: Int, isFavourite: Bool) async {
        // Without an iCloud account the save and delete quietly do nothing, so the change stays pending.
        guard cloudKitDataService.hasUbiquityIdentityToken, pendingChanges.changes[id] == isFavourite else { return }
        let record = favouriteRecord(id: id)
        do {
            if isFavourite {
                record.setValue(id, forKey: ProduceRecordKey.id)
                try await cloudKitDataService.saveItem(record, in: .private)
            } else {
                try await cloudKitDataService.deleteItem(record, in: .private)
            }
        } catch let error as CKError where error.code == .serverRecordChanged {
            // Another device already saved this favourite.
        } catch {
            return
        }
        pendingChanges.clear(id, ifStill: isFavourite)
    }
}
