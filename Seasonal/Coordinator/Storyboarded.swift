//
//  Storyboarded.swift
//  Seasonal
//
//  Created by Clint Thomas on 19/8/20.
//  Copyright © 2020 Clint Thomas. All rights reserved.
//

import Foundation
import UIKit

protocol Storyboarded {
    // what ever conforms to this will instantiate itself
    static func instantiate() -> Self
}

// Same storyboard id as their classname.
extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        let id = String(describing: self)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: id) as! Self
    }
}
