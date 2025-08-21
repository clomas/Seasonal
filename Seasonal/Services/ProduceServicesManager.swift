//
//  ProduceServicesManager.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import Foundation

@available(iOS 26, *)
actor ProduceServicesManager {

	static func getDataFromCloudKit(for location: StateLocation) async -> [Produce] {
		let cloudKitService: ProduceCloudDataService = .init(location: location)

		let data = Task {
			await cloudKitService.getData(for: location)
		}
		return await data.value
	}

	static func updateLike(id: Int, liked: Bool) async {
		let cloudKitService: ProduceCloudDataService = await .init(location: StateLocation(rawValue: GlobalSettings.location.state) ?? .noState)
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

