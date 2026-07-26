//
//  ProduceServicesManager.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import CloudKit
import Foundation

@available(iOS 26, *)
actor ProduceServicesManager {

	static func getDataFromCloudKit(for location: StateLocation) async -> Result<[Produce], CKError> {
		let cloudKitService: ProduceCloudDataService = .init(location: location)

        return switch await Task(operation: { await cloudKitService.getData(for: location) }).value {
        case let .success(produce):
            .success(produce)
        case let .failure(error):
            .failure(error)
        }
	}

	static func getLikesFromCloudKit(for location: StateLocation, basedOn baseProduce: [Produce]) async -> Result<[Produce], CKError> {
		let cloudKitService: ProduceCloudDataService = .init(location: location)

		return switch await Task(operation: { await cloudKitService.getLikes(basedOn: baseProduce) }).value {
		case let .success(produce):
			.success(produce)
		case let .failure(error):
			.failure(error)
		}
	}

	static func updateLike(id: Int, liked: Bool) async {
		let cloudKitService: ProduceCloudDataService = await .init(
			location: StateLocation(rawValue: GlobalSettings.location.state) ?? .noState
		)
		let likedProduce: LikedProduce = LikedProduce(id: id)

		if liked {
			likedProduce.saveItem()
			await cloudKitService.saveLikeToPrivateDatabaseInCloudKit(id: id)
		} else {
			likedProduce.deleteItem()
			await cloudKitService.deleteRecordsInPrivateDatabase(id: id)
		}
	}
}

