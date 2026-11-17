//
//  UserDefaults+BoolDefault.swift
//  Seasonal
//
//  Created by Clint Thomas on 13/11/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Foundation

extension UserDefaults {
    // Launch arguments are stored as strings such as "YES", which `as? Bool` rejects.
    func bool(forKey key: String, default defaultValue: Bool) -> Bool {
        object(forKey: key) != nil ? bool(forKey: key) : defaultValue
    }
}
