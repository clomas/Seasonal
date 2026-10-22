//
//  PendingFavouriteChanges.swift
//  Seasonal
//
//  Created by Clint Thomas on 22/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Foundation
import Synchronization

/// Favourite changes made on this device that CloudKit hasn't confirmed: `true` adds, `false`
/// removes. Once fetched, the cloud is the source of truth, so these are what tell an offline
/// change apart from one made on another device.
// UserDefaults is thread-safe but not marked Sendable; read-modify-writes are serialised by the lock.
@available(iOS 26, *)
final class PendingFavouriteChanges: @unchecked Sendable {

    private let changesKey = "pendingFavouriteChanges"
    private let hasSyncedKey = "hasSyncedFavourites"
    private let defaults: UserDefaults
    private let lock = Mutex(())

    var changes: [Int: Bool] {
        lock.withLock { _ in stored }
    }

    /// False until the first sync, when favourites saved before changes were tracked are adopted.
    var hasSynced: Bool {
        defaults.bool(forKey: hasSyncedKey)
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func record(_ id: Int, isFavourite: Bool) {
        lock.withLock { _ in
            var changes = stored
            changes[id] = isFavourite
            store(changes)
        }
    }

    /// Leaves a newer change for `id`, recorded while CloudKit was confirming this one, in place.
    func clear(_ id: Int, ifStill isFavourite: Bool) {
        lock.withLock { _ in
            var changes = stored
            guard changes[id] == isFavourite else { return }
            changes[id] = nil
            store(changes)
        }
    }

    func markSynced() {
        defaults.set(true, forKey: hasSyncedKey)
    }

    private var stored: [Int: Bool] {
        let raw = defaults.dictionary(forKey: changesKey) as? [String: Bool] ?? [:]
        return Dictionary(uniqueKeysWithValues: raw.compactMap { key, value in Int(key).map { ($0, value) } })
    }

    // Property lists only allow string keys.
    private func store(_ changes: [Int: Bool]) {
        defaults.set(Dictionary(uniqueKeysWithValues: changes.map { (String($0.key), $0.value) }), forKey: changesKey)
    }
}
