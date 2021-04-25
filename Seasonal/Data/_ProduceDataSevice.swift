//
//  _ProduceDataSevice.swift
//  Seasonal
//
//  Created by Clint Thomas on 2/3/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

protocol _ProduceDataServiceProtocol {
	func updateLike()
	func test()
}

class _ProduceDataService {

	func updateLike(id: Int, liked: Bool) {
		CloudKitDataHandler.instance.saveLikeToPrivateDatabaseInCloudKit(id: id)

		// Update in local database
		// TODO: Change to coredata
		let likedProduce = LikedProduce(id: id)

		if liked == true {
			likedProduce.saveItem()
		} else {
			likedProduce.deleteItem()
		}
	}

	func test() {
		//
	}
}


