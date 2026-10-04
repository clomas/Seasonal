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
    var likesResult: Result<[Produce], CKError> = .success([])
    private(set) var produceRequests: [StateLocation] = []
    private(set) var likesRequests: [[Int]] = []
    private(set) var likeUpdates: [Int: Bool] = [:]

    func produce(for location: StateLocation) async -> Result<[Produce], CKError> {
        produceRequests.append(location)
        return produceResult
    }

    func likes(for location: StateLocation, basedOn baseProduce: [Produce]) async -> Result<[Produce], CKError> {
        likesRequests.append(baseProduce.map(\.id))
        return likesResult
    }

    func updateLike(id: Int, liked: Bool) async {
        likeUpdates[id] = liked
    }
}
