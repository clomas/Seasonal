//
//  ProduceDataSevice.swift
//  Seasonal
//
//  Created by Clint Thomas on 2/3/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

struct ProduceDataService {

	let cloudKitService = CloudKitDataServiceOld()

	func updateLike(id: Int, liked: Bool) {

		let likedProduce: LikedProduceOld = LikedProduceOld(id: id)

		if liked {
			likedProduce.saveItem()
			cloudKitService.saveLikeToPrivateDatabaseInCloudKit(id: id, result: { _ in })
		} else {
			likedProduce.deleteItem()
			cloudKitService.deleteRecordsInPrivateDatabase(id: id, result: { _ in })
		}
	}
}
