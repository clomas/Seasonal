//
//  PendingUnlikes.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Foundation
import Synchronization

/// Unlikes whose CloudKit delete hasn't succeeded yet. Cloud and local likes are merged on
/// launch, so without this a delete that failed offline would bring the like back.
@available(iOS 26, *)
enum PendingUnlikes {

    private static let key = "pendingUnlikes"
    private static let lock = Mutex(())

    static var ids: Set<Int> {
        lock.withLock { _ in stored }
    }

    static func insert(_ id: Int) {
        lock.withLock { _ in store(stored.union([id])) }
    }

    static func remove(_ id: Int) {
        lock.withLock { _ in store(stored.subtracting([id])) }
    }

    private static var stored: Set<Int> {
        Set(UserDefaults.standard.array(forKey: key) as? [Int] ?? [])
    }

    private static func store(_ ids: Set<Int>) {
        UserDefaults.standard.set(Array(ids), forKey: key)
    }
}
