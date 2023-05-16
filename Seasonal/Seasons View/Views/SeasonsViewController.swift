//
//  SeasonsViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 21/4/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import UIKit
import CoreHaptics

class SeasonsViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, SeasonsLikeButtonDelegate {

	private var searchController: UISearchController = UISearchController(searchResultsController: nil)
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var nothingToShowLabel: UILabel!
	@IBOutlet weak var menuBar: MenuBarCollectionView!

	var viewModel: SeasonsViewModel?
	private var setFeedbackToOccur: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
		setUpView()

		viewModel?.reloadTableView = { [weak self] in
			self?.tableView.reloadData()
			self?.title = self?.viewModel?.updateTitle()
		}
    }

	override func viewWillAppear(_ animated: Bool) {
		navigationController?.setNavigationBarHidden(false, animated: animated)
	}

	func likeButtonWasTapped(cell: SeasonsTableViewCell) {
		if let id: Int = cell.id {
			viewModel?.likeToggle(id: id, liked: cell.likeButton.isSelected)
			UINotificationFeedbackGenerator().notificationOccurred(.success)
		}
	}

	private func updateLabelBehindTableView(numberOfRows: Int) {

		if numberOfRows > 0 {
			nothingToShowLabel.text = ""
			setFeedbackToOccur = true
		} else {

			if viewModel?.searchString.isEmpty == false {
				nothingToShowLabel.text = "No Search Results"

				if setFeedbackToOccur == true {
					UINotificationFeedbackGenerator().notificationOccurred(.error)
					setFeedbackToOccur = false
				}
			}

		}
	}

	@IBAction func backButtonWasTapped(_ sender: Any) {
		viewModel?.backButtonWasTapped()
	}

	@IBAction func infoButtonWasTapped(_ sender: Any) {
		viewModel?.infoButtonWasTapped()
	}

	// MARK: Setup

	private func setUpView() {
		tableView.dataSource = self
		title = viewModel?.updateTitle()

		setUpSearchController()
		setupMenuBar()
	}

	private func setupMenuBar() {
		menuBar.viewModel = .init(season: viewModel?.season ?? .summer)
		menuBar.viewModel?.delegate = viewModel.self
	}

	private func setUpSearchController() {
		let searchController: UISearchController = UISearchController(searchResultsController: nil)
		searchController.hidesNavigationBarDuringPresentation = false
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.searchBarStyle = .minimal
		searchController.searchBar.isTranslucent = false
		searchController.searchResultsUpdater = self
		// for cancel button
		searchController.searchBar.tintColor = UIColor.SearchBar.tint
		searchController.hidesNavigationBarDuringPresentation = false

		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
	}
}

// MARK: Table View

extension SeasonsViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let viewModel, let season: Season = Season(rawValue: viewModel.season.rawValue) else { return 0 }

		let rowsCount: Int = viewModel.filter(by: season, matching: viewModel.searchString, of: viewModel.category).count
		updateLabelBehindTableView(numberOfRows: rowsCount)

		return rowsCount
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let viewModel,
			  let season: Season = Season(rawValue: viewModel.season.rawValue),
	          let cell: SeasonsTableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.SeasonsTableViewCell) as? SeasonsTableViewCell
			else { return ProduceMonthInfoViewCell()
		}

		let produceModel: Produce = viewModel.filter(by: season, matching: viewModel.searchString, of: viewModel.category)[indexPath.row]

		cell.updateViews(produce: produceModel)
		cell.likeButtonDelegate = self

		return cell

	}
}

// MARK: Search Bar Delegates
extension SeasonsViewController: UISearchControllerDelegate {

	func updateSearchResults(for searchController: UISearchController) {
		viewModel?.searchString = searchController.searchBar.text!
		tableView.reloadData()
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		viewModel?.searchString = searchText
	}
}
