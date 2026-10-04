//
//  ProduceDiskCaching.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

protocol ProduceDiskCaching {
    func load(for location: StateLocation) -> [Produce]?
    func save(_ produce: [Produce], for location: StateLocation)
    func clear()
}
