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

	func produce(for location: StateLocation) async -> Result<[Produce], CKError> {
		await ProduceCloudDataService(location: location).getData()
	}

	func likes(for location: StateLocation, basedOn baseProduce: [Produce]) async -> Result<[Produce], CKError> {
		await ProduceCloudDataService(location: location).getLikes(basedOn: baseProduce)
	}

	func updateLike(id: Int, liked: Bool) async {
		let location = StateLocation(rawValue: GlobalSettings.location.state) ?? .noState
		let service = ProduceCloudDataService(location: location)
		let likedProduce = LikedProduce(id: id)

		if liked {
			likedProduce.saveItem()
			await service.saveLike(id: id)
		} else {
			likedProduce.deleteItem()
			await service.deleteLike(id: id)
		}
	}
}
