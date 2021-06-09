//
//  SeasonsViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 21/4/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import UIKit

class SeasonsViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, UIGestureRecognizerDelegate, SeasonsLikeButtonDelegate {

	private var searchController = UISearchController(searchResultsController: nil)
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var nothingToShowLabel: UILabel!
	@IBOutlet weak var menuBar: MenuBarCollectionView!

	var viewModel: SeasonsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
		setUpView()

		viewModel.reloadTableView = { [weak self] in
			self?.tableView.reloadData()
			self?.title = self?.viewModel.updateTitle()
		}
    }

	func likeButtonTapped(cell: SeasonsTableViewCell) {
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

	@IBAction func backButtonTapped(_ sender: Any) {
		viewModel.backButtonTapped()
	}

	@IBAction func infoButtonTapped(_ sender: Any) {
		viewModel.infoButtonTapped()
	}

	// MARK: Setup

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

	private func setUpNavigationControllerView() {
		let searchController = UISearchController(searchResultsController: nil)
		searchController.hidesNavigationBarDuringPresentation = false
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.searchBarStyle = .minimal
		searchController.searchBar.isTranslucent = false
		searchController.searchResultsUpdater = self
		// for cancel button
		searchController.searchBar.tintColor = UIColor.SearchBar.tint
		searchController.hidesNavigationBarDuringPresentation = false
		self.navigationController?.navigationBar.isTranslucent = false
		// self.navigationController?.navigationBar.tintColor = UIColor.NavigationBar.searchBarTint
		self.navigationController?.navigationBar.barTintColor = UIColor.NavigationBar.tint
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		self.definesPresentationContext = true
	}
}

// MARK: Table View

extension SeasonsViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let season =  Season(rawValue: viewModel.season.rawValue) {
			return viewModel.filter(by: season, matching: viewModel.searchString, of: viewModel.category).count
		} else {
			return 0
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if let season = Season(rawValue: viewModel.season.rawValue) {

			if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.SeasonsTableViewCell) as? SeasonsTableViewCell {
				cell.likeButtonDelegate = self
				let produce = viewModel.filter(by: season, matching: viewModel.searchString, of: viewModel.category)[indexPath.row]
				cell.updateViews(produce: produce)
				return cell
			} else {
				return ProduceMonthInfoViewCell()
			}
		} else {
			return ProduceMonthInfoViewCell()
		}
	}
}

// MARK: Search Bar Delegates
extension SeasonsViewController: UISearchControllerDelegate {

	func updateSearchResults(for searchController: UISearchController) {
		self.viewModel.searchString = searchController.searchBar.text!
		tableView.reloadData()
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		self.viewModel.searchString = searchText
	}
}
