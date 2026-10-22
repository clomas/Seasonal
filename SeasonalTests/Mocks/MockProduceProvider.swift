//
//  MockProduceProvider.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 4/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import CloudKit
@testable import Seasonal

@MainActor
final class MockProduceProvider: ProduceProviding {

    var produceResult: Result<[Produce], CKError> = .success([])
    var favouritesResult: [Produce] = []
    private(set) var produceRequests: [StateLocation] = []
    private(set) var favouritesRequests: [[Int]] = []
    private(set) var favouriteUpdates: [Int: Bool] = [:]

    func produce(for location: StateLocation) async -> Result<[Produce], CKError> {
        produceRequests.append(location)
        return produceResult
    }

    func favourites(for location: StateLocation, basedOn baseProduce: [Produce]) async -> [Produce] {
        favouritesRequests.append(baseProduce.map(\.id))
        return favouritesResult
    }

    func updateFavourite(id: Int, isFavourite: Bool) async {
        favouriteUpdates[id] = isFavourite
    }
}
