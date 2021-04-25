//
//  _SeasonsViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 21/4/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import UIKit

class _SeasonsViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, UIGestureRecognizerDelegate, _SeasonsLikeButtonDelegate {

		private var searchController = UISearchController(searchResultsController: nil)
		@IBOutlet weak var tableView: UITableView!
		@IBOutlet weak var nothingToShowLabel: UILabel!
		@IBOutlet weak var menuBar: _MenuBar!

		// View models
		var viewModel: _SeasonsViewModel!
		// var menuBarViewModel: MenuBarCellViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
		setUpView()

		viewModel.reloadTableView = { [weak self] in
			self?.tableView.reloadData()
			self?.setContextualTitle()
		}
    }

	private func setUpView() {
		self.tableView.dataSource = self
		setContextualTitle()
		setUpNavigationControllerView()
		setupMenuBar()
	}

	func setupMenuBar() {
		menuBar.viewModel = .init(month: nil, season: viewModel.season, viewDisplayed: .seasons)
		menuBar.viewModel.delegate = viewModel.self
	}

	// TODO: search cancel is blue
	func updateSearchResults(for searchController: UISearchController) {
		//
	}

	

	func likeButtonTapped(cell: _SeasonsTableViewCell) {
		//
	}

	func menuBarScrollFinished() {
		//
	}

	private func hideTableIfEmpty() {
		if viewModel.searchString.count > 0 {
			nothingToShowLabel.text = "No Search Results"
		}
		if self.tableView.numberOfRows(inSection: 0) == 0 {
			nothingToShowLabel.text = ""
		}
	}

	// TODO: Finish this off with filters
	private func setContextualTitle() {
		var titleString = ""

		//if stateViewModel.status.onPage == .favourites {
		//	titleString = FAVOURITES
		//} else if stateViewModel.status.onPage == .months {
		titleString = String(describing: viewModel.season).capitalized
		//}

		//		switch stateViewModel.status.current.filter {
		//		case .cancelled, .all:
		self.title = titleString
		//		case .fruit, .vegetables, .herbs:
		//			self.title = "\(stateViewModel.status.current.filter.asString.capitalized) in \(titleString)"
		//		}
	}

	private func setUpNavigationControllerView() {
		let searchController = UISearchController(searchResultsController:  nil)
		searchController.hidesNavigationBarDuringPresentation = false
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.searchBarStyle = .minimal
		searchController.searchBar.isTranslucent = false
		searchController.searchResultsUpdater = self
		// for cancel button
		searchController.searchBar.tintColor = UIColor.SearchBar.tint
		searchController.hidesNavigationBarDuringPresentation = false
		self.navigationController?.navigationBar.isTranslucent = false
		//self.navigationController?.navigationBar.tintColor = UIColor.NavigationBar.searchBarTint
		self.navigationController?.navigationBar.barTintColor = UIColor.NavigationBar.tint
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		self.definesPresentationContext = true
	}
}

// MARK: Table View
extension _SeasonsViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let season =  Season(rawValue: viewModel.season.rawValue) {
			print(viewModel.filter(by: season, matching: viewModel.searchString, of: viewModel.filter).count)
			return viewModel.filter(by: season, matching: viewModel.searchString, of: viewModel.filter).count
		} else {
			return 0
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if let season = Season(rawValue: viewModel.season.rawValue) {
			
			if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.SeasonsTableViewCell) as? _SeasonsTableViewCell {
				cell.likeButtonDelegate = self
				let produce = viewModel.filter(by: season, matching: viewModel.searchString, of: viewModel.filter)[indexPath.row]
				cell.updateViews(produce: produce) 
				return cell
			} else {
				return SelectedCategoryViewCell()
			}
		} else {
			return SelectedCategoryViewCell()
		}
	}
}
