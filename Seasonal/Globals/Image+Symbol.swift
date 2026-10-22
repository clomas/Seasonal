//
//  Image+Symbol.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import SwiftUI

extension Image {
    static let favourites = Image(systemName: Symbol.favourites)
    static let favouritesFilled = Image(systemName: Symbol.favouritesFilled)
    static let search = Image(systemName: Symbol.search)
    static let nothingToShow = Image(systemName: Symbol.nothingToShow)

    init(symbol name: String) {
        if UIImage(named: name) != nil {
            self.init(name)
        } else {
            self.init(systemName: name)
        }
    }
}
