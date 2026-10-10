//
//  InMemoryProduceDiskCache.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 4/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

@testable import Seasonal

final class InMemoryProduceDiskCache: ProduceDiskCaching {

    private var stored: [StateLocation: [Produce]] = [:]

    func load(for location: StateLocation) -> [Produce]? {
        stored[location]
    }

    func save(_ produce: [Produce], for location: StateLocation) {
        stored[location] = produce
    }
}
