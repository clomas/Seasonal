//
//  Bundle+AppVersion.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Foundation

extension Bundle {
    var shortVersion: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
