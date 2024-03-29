//
//  LikedProduceModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 2/11/20.
//  Copyright © 2020 Clint Thomas. All rights reserved.
//

import Foundation

struct LikedProduce: Codable {

    var id: Int

    func saveItem() {
        LocalDataHandler.save(self, with: "\(id)")
    }

    func deleteItem() {
        LocalDataHandler.delete("\(id)")
    }
}
