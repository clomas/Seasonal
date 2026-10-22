//
//  FavouriteSync.swift
//  Seasonal
//
//  Created by Clint Thomas on 22/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

/// Works out the favourites after a fetch. With the cloud reachable it's the source of truth and
/// this device's pending changes are applied on top; without it, the local favourites stand.
struct FavouriteSync: Equatable {

    let favouriteIDs: Set<Int>
    /// Local favourites from before changes were tracked, adopted as pending adds on the first sync.
    let adopted: Set<Int>
    let toSave: Set<Int>
    let toDelete: Set<Int>
    /// Pending changes the cloud already reflects.
    let confirmed: [Int: Bool]

    init(cloudIDs: Set<Int>?, localIDs: Set<Int>, pending: [Int: Bool], hasSynced: Bool) {
        guard let cloudIDs else {
            favouriteIDs = localIDs
            adopted = []
            toSave = []
            toDelete = []
            confirmed = [:]
            return
        }

        adopted = hasSynced ? [] : localIDs.subtracting(cloudIDs).filter { pending[$0] == nil }
        let changes = pending.merging(adopted.map { ($0, true) }) { current, _ in current }
        let adds = Set(changes.filter(\.value).keys)
        let removals = Set(changes.filter { !$0.value }.keys)

        favouriteIDs = cloudIDs.union(adds).subtracting(removals)
        toSave = adds.subtracting(cloudIDs)
        toDelete = removals.intersection(cloudIDs)
        confirmed = changes.filter { id, isFavourite in cloudIDs.contains(id) == isFavourite }
    }
}
