//
//  ProduceDataSevice.swift
//  Seasonal
//
//  Created by Clint Thomas on 2/3/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

class ProduceDataService {

	func updateLike(id: Int, liked: Bool) {
		// Update in local database
		let likedProduce: LikedProduce = LikedProduce(id: id)
		liked ? likedProduce.saveItem() : likedProduce.deleteItem()
	}
}
