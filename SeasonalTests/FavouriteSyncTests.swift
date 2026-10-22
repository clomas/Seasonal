//
//  FavouriteSyncTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 22/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Testing
@testable import Seasonal

struct FavouriteSyncTests {

    @Test func cloudIsTheSourceOfTruthOnceSynced() {
        let sync = FavouriteSync(cloudIDs: [1, 2], localIDs: [2, 3], pending: [:], hasSynced: true)

        #expect(sync.favouriteIDs == [1, 2])
        #expect(sync.toSave.isEmpty)
        #expect(sync.toDelete.isEmpty)
    }

    @Test func removalOnAnotherDeviceIsNotResurrected() {
        let sync = FavouriteSync(cloudIDs: [], localIDs: [5], pending: [:], hasSynced: true)

        #expect(sync.favouriteIDs.isEmpty)
        #expect(sync.toSave.isEmpty)
    }

    @Test func pendingAddIsKeptAndRetried() {
        let sync = FavouriteSync(cloudIDs: [], localIDs: [5], pending: [5: true], hasSynced: true)

        #expect(sync.favouriteIDs == [5])
        #expect(sync.toSave == [5])
    }

    @Test func pendingRemovalIsDroppedAndRetried() {
        let sync = FavouriteSync(cloudIDs: [5], localIDs: [], pending: [5: false], hasSynced: true)

        #expect(sync.favouriteIDs.isEmpty)
        #expect(sync.toDelete == [5])
    }

    @Test func changesTheCloudAlreadyReflectsAreConfirmed() {
        let sync = FavouriteSync(cloudIDs: [1], localIDs: [1], pending: [1: true, 2: false], hasSynced: true)

        #expect(sync.confirmed == [1: true, 2: false])
        #expect(sync.toSave.isEmpty)
        #expect(sync.toDelete.isEmpty)
    }

    @Test func firstSyncAdoptsLocalOnlyFavourites() {
        let sync = FavouriteSync(cloudIDs: [1], localIDs: [1, 2], pending: [:], hasSynced: false)

        #expect(sync.adopted == [2])
        #expect(sync.favouriteIDs == [1, 2])
        #expect(sync.toSave == [2])
    }

    @Test func firstSyncKeepsAPendingRemovalOverALocalFavourite() {
        let sync = FavouriteSync(cloudIDs: [], localIDs: [2], pending: [2: false], hasSynced: false)

        #expect(sync.adopted.isEmpty)
        #expect(sync.favouriteIDs.isEmpty)
    }

    @Test func unreachableCloudKeepsLocalFavourites() {
        let sync = FavouriteSync(cloudIDs: nil, localIDs: [3], pending: [3: true, 4: false], hasSynced: true)

        #expect(sync.favouriteIDs == [3])
        #expect(sync.adopted.isEmpty)
        #expect(sync.toSave.isEmpty)
        #expect(sync.toDelete.isEmpty)
        #expect(sync.confirmed.isEmpty)
    }
}
