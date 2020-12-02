//
//  NavigationController.swift
//  Seasonal
//
//  Created by Clint Thomas on 5/3/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//
import UIKit
import Foundation

class CustomNavigationController: UINavigationController {

    override func awakeFromNib() {
       super.awakeFromNib()
    }

    override func viewDidLoad() {
        setUpNavigationControllerAppearance()
    }

    func setUpNavigationControllerAppearance() {
        let navbarAppearance = UINavigationBar.appearance()
        navbarAppearance.setBackgroundImage(UIImage(), for: .default)
        navbarAppearance.shadowImage = UIImage()
        navbarAppearance.backgroundColor = UIColor.NavigationBar.tint
        self.navigationBar.barTintColor = UIColor.NavigationBar.tint
        self.navigationBar.isHidden = true
    }
}

