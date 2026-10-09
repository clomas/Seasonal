//
//  LikedProduceOld.swift
//  Seasonal
//
//  Created by Clint Thomas on 2/11/20.
//  Copyright © 2020 Clint Thomas. All rights reserved.
//

import Foundation

struct LikedProduceOld: Codable {

    let id: Int

    func saveItem() {
        LocalDataHandlerOld.save(self, with: "\(id)")
    }

    func deleteItem() {
        LocalDataHandlerOld.delete("\(id)")
    }
}
