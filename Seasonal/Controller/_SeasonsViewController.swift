//
//  _SeasonsViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 21/4/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import UIKit

class _SeasonsViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, UIGestureRecognizerDelegate, _SeasonsLikeButtonDelegate {

		// TODO: maybe bubble up to coordinator instead of calling it here.
		weak var coordinator: _MainViewCoordinator?
	private var searchController = UISearchController(searchResultsController: nil)
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var nothingToShowLabel: UILabel!
	@IBOutlet weak var menuBar: _MenuBarCollectionView!

	// View models
	var viewModel: _SeasonsViewModel!
	// var menuBarViewModel: MenuBarCellViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
		setUpView()

		viewModel.reloadTableView = { [weak self] in
			self?.tableView.reloadData()
			self?.title = self?.viewModel.updateTitle()
		}
    }

	private func setUpView() {
		self.tableView.dataSource = self
		self.title = viewModel.updateTitle()
		setUpNavigationControllerView()
		setupMenuBar()
	}

	func setupMenuBar() {
		menuBar.viewModel = .init(month: nil, season: viewModel.season, viewDisplayed: .seasons)
		menuBar.viewModel.delegate = viewModel.self
	}

	func likeButtonTapped(cell: _SeasonsTableViewCell) {
		if let id = cell.id {
			viewModel.likeToggle(id: id, liked: cell.likeButton.isSelected)
		}
	}

	private func hideTableIfEmpty() {
		if viewModel.searchString.count > 0 {
			nothingToShowLabel.text = "No Search Results"
		}
		if self.tableView.numberOfRows(inSection: 0) == 0 {
			nothingToShowLabel.text = ""
		}
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

	@IBAction func backButtonTapped(_ sender: Any) {
		coordinator?.seasonsBackButtonTapped()
	}

	@IBAction func infoButtonTapped(_ sender: Any) {
		viewModel.infoButtonTapped()
	}

	// TODO: Check this is working
	deinit {
		print("SEASONS VIEW DEINIT")
	}
}

// MARK: Table View
extension _SeasonsViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let season =  Season(rawValue: viewModel.season.rawValue) {
			print(viewModel.filter(by: season, matching: viewModel.searchString, of: viewModel.category).count)
			return viewModel.filter(by: season, matching: viewModel.searchString, of: viewModel.category).count
		} else {
			return 0
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if let season = Season(rawValue: viewModel.season.rawValue) {
			
			if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.SeasonsTableViewCell) as? _SeasonsTableViewCell {
				cell.likeButtonDelegate = self
				let produce = viewModel.filter(by: season, matching: viewModel.searchString, of: viewModel.category)[indexPath.row]
				cell.updateViews(produce: produce) 
				return cell
			} else {
				return _ProduceMonthInfoViewCell()
			}
		} else {
			return _ProduceMonthInfoViewCell()
		}
	}
}

// MARK: Search Bar Delegates
extension _SeasonsViewController: UISearchControllerDelegate {

	func updateSearchResults(for searchController: UISearchController) {
		self.viewModel.searchString = searchController.searchBar.text!
		tableView.reloadData()
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		self.viewModel.searchString = searchText
	}
}


