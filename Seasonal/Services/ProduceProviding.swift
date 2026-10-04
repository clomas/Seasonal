//
//  ProduceProviding.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import CloudKit

@MainActor
protocol ProduceProviding {
	func produce(for location: StateLocation) async -> Result<[Produce], CKError>
	func likes(for location: StateLocation, basedOn baseProduce: [Produce]) async -> Result<[Produce], CKError>
	func updateLike(id: Int, liked: Bool) async
}
