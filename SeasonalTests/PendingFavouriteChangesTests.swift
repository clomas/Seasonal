//
//  PendingFavouriteChangesTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 22/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Foundation
import Testing
@testable import Seasonal

struct PendingFavouriteChangesTests {

    private let changes: PendingFavouriteChanges

    init() throws {
        let defaults = try #require(UserDefaults(suiteName: UUID().uuidString))
        changes = PendingFavouriteChanges(defaults: defaults)
    }

    @Test func recordsAddsAndRemovals() {
        changes.record(1, isFavourite: true)
        changes.record(2, isFavourite: false)

        #expect(changes.changes == [1: true, 2: false])
    }

    @Test func latestChangeWins() {
        changes.record(1, isFavourite: true)
        changes.record(1, isFavourite: false)

        #expect(changes.changes == [1: false])
    }

    @Test func clearsAConfirmedChange() {
        changes.record(1, isFavourite: true)
        changes.clear(1, ifStill: true)

        #expect(changes.changes.isEmpty)
    }

    @Test func keepsANewerChangeWhenClearing() {
        changes.record(1, isFavourite: true)
        changes.record(1, isFavourite: false)
        changes.clear(1, ifStill: true)

        #expect(changes.changes == [1: false])
    }

    @Test func remembersTheFirstSync() {
        #expect(changes.hasSynced == false)

        changes.markSynced()

        #expect(changes.hasSynced)
    }
}
