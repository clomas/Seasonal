//
//  LocalDataStorage.swift
//  Seasonal
//
//  Created by Clint Thomas on 9/11/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import Foundation

struct LikedProduce: Codable {
    
    var id: Int

    func saveItem() {
        DataManager.save(self, with: "\(id)")
    }
    
    func deleteItem() {
        DataManager.delete("\(id)")
    }
}


