//
//  SearchController.swift
//  Seasonal
//
//  Created by Clint Thomas on 12/11/20.
//  Copyright © 2020 Clint Thomas. All rights reserved.
//

import Foundation
import UIKit



class SearchController: UISearchController, UISearchResultsUpdating, UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    public var searchString: String = ""
        func updateSearchResults(for searchController: UISearchController) {
            self.searchString = searchController.searchBar.text!
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.searchString = searchText
        }

    func configureSearchController() {
        let searchController = UISearchController(searchResultsController:  nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        self.navigationController?.navigationBar.isTranslucent = false
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.isTranslucent = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.tintColor = UIColor.NavigationBar.searchBarTint
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        self.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
    }


}
