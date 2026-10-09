//
//  ProduceServicesManager.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import CloudKit

@available(iOS 26, *)
struct ProduceServicesManager: ProduceProviding {

	private let localLikes = LocalLikes()

	func produce(for location: StateLocation) async -> Result<[Produce], CKError> {
		await ProduceCloudDataService(location: location, localLikes: localLikes).getData()
	}

	func likes(for location: StateLocation, basedOn baseProduce: [Produce]) async -> [Produce] {
		await ProduceCloudDataService(location: location, localLikes: localLikes).getLikes(basedOn: baseProduce)
	}

	func updateLike(id: Int, liked: Bool) async {
		let location = StateLocation(rawValue: GlobalSettings.location.state) ?? .noState
		let service = ProduceCloudDataService(location: location, localLikes: localLikes)

		if liked {
			localLikes.save(id)
			await service.saveLike(id: id)
		} else {
			localLikes.delete(id)
			await service.deleteLike(id: id)
		}
	}
}
