//
//  _MainViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 25/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import UIKit
import InfiniteLayout

// TODO: make all delegates weak.

class _MainViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating {

	var viewModel: _MainViewModel!
	@IBOutlet weak var infiniteMonthCollectionView: InfiniteCollectionView!
	@IBOutlet weak var menuBar: _MenuBarCollectionView!
	var searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
		setUpView()

		viewModel.reloadTableView = { [weak self] in
			if let month = self?.viewModel.month {
				self?.infiniteMonthCollectionView.scrollToItem(at: .init(row: month.rawValue, section: 0),
															   at: .centeredHorizontally,
															   animated: false)
			}
			self?.infiniteMonthCollectionView.reloadData()
			self?.title = self?.viewModel.updateTitle()
		}
		// Called from MonthPickerViewController to update -
		// month icon,
		// month in the table view
		// navigation bar title
		viewModel.updateMenuBar = { [weak self] in
			if let index = self?.viewModel.viewDisplayed.rawValue {
				self?.menuBar.viewModel.toggleSelectedCells(indexSelected: index)
				if let month = self?.viewModel.month {
					self?.menuBar.updateMonthIconImage(to: month)
				}
			}
		}
    }

	private func setUpView() {
		self.infiniteMonthCollectionView.delegate = self
		self.infiniteMonthCollectionView.dataSource = self
		setUpNavigationControllerView()
		setupMenuBar()
		setupCollectionView()
		self.title = viewModel.updateTitle()
	}

	// Init child viewModel & assign delegate between child and parent viewModel
	private func setupMenuBar() {
		menuBar.viewModel = .init(month: viewModel.month, season: nil, viewDisplayed: viewModel.viewDisplayed)
		menuBar.viewModel.delegate = viewModel.self
	}

	// If navigating to SeasonsViewController I need to toggle the selected menuBar after it disappears.
	// after changing it,
	override func viewDidDisappear(_ animated: Bool) {
		self.searchController.isActive = false
		if menuBar.viewModel.selectedView == .seasons || menuBar.viewModel.selectedView == .monthPicker {
			if let previousView = menuBar.viewModel.mainViewIconSelected?.rawValue {
				menuBar.viewModel.toggleSelectedCells(indexSelected: previousView)
				menuBar.reloadData()
			} 
		}
	}

	private func setupCollectionView() {
		if let flowLayout = infiniteMonthCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
			flowLayout.scrollDirection = .horizontal
			flowLayout.minimumLineSpacing = 0
		}
		infiniteMonthCollectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		infiniteMonthCollectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		infiniteMonthCollectionView?.isPagingEnabled = true
	}

	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
	}

	// Scroll to correct month before view is presented
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		if viewModel.monthsProduce.count > 0 {
			let indexPath = IndexPath(item: viewModel.month.rawValue, section: 0)
			infiniteMonthCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
		}
	}

	// MARK: Title

	/// Scrollview Paging changes the title
	/// - Parameter newTitle: newTitle is the month determined from the index of the main tableView
	/// this only runs if the infiniteMonthCollectionView is visible, otherwise the heading is "Favourites"
	private func setTitleFromScrollViewPaged(newTitle: String) {
		if viewModel.viewDisplayed == .months {
			if (newTitle).isEmpty == false { // only proceed with a valid value for newTitle.
				// CATransition code
				let titleAnimation = CATransition()
				titleAnimation.duration = 0.5
				titleAnimation.type = CATransitionType.fade
				titleAnimation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
				// this is a detail view controller, so we must grab the reference
				// to the parent view controller's navigation controller
				// then cycle through until we find the title labels.
				if let subviews = self.navigationController?.navigationBar.subviews {
					for navigationItem in subviews {
						for itemSubView in navigationItem.subviews {
							if let largeLabel = itemSubView as? UILabel {
								largeLabel.layer.add(titleAnimation, forKey: "changeTitle")
							}
						}
					}
				}
				// finally set the title
				navigationItem.title = newTitle
			}
		}
	}

	// TODO: this from coord
	@IBAction func infoButtonTapped(_ sender: Any) {
		viewModel.infoButtonTapped()
	}

	// MARK: Search controller setup

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
		self.navigationController?.navigationBar.barTintColor = UIColor.NavigationBar.tint
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		self.definesPresentationContext = true
	}
}


// MARK: Infinite Collection View Data / Delegate

extension _MainViewController: UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch viewModel.viewDisplayed {
		case .favourites:
			self.infiniteMonthCollectionView.isScrollEnabled = false
			return 1
		case .months:
			self.infiniteMonthCollectionView.isScrollEnabled = true
			return 12
		default:
			return 12
		}
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants._MonthTableCell, for: indexPath) as! _MonthTableCollectionViewCell
		cell.tag = (indexPath.item % 12)
		cell.viewModel = viewModel
		cell.collectionReloadData()
		return cell
	}
}

extension _MainViewController: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
	}
}

// MARK: CollectionView Layout

extension _MainViewController: UICollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return collectionView.frame.height
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
	}

	// MARK: ScrollView did end decelerating

	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

		// this is the page currently displayed
		let page = scrollView.contentOffset.x / scrollView.bounds.size.width
		if let updatedMonth = Month.init(rawValue: (Int(page) % 12)) {
			// update menubar before calling method for animation of month icon
			// TODO: Need this?
			//menuBar.currentMonth = updatedMonth
			if viewModel.previousMonth != updatedMonth {
				menuBar.monthIconCarouselAnimation(from: viewModel.month, to: updatedMonth)
				viewModel.previousMonth = updatedMonth
			}
			viewModel.month = updatedMonth
		}

		// override the title because it can be wrong if not scrolled properly
		var visibleRect = CGRect()
		visibleRect.origin = infiniteMonthCollectionView.contentOffset
		visibleRect.size = infiniteMonthCollectionView.bounds.size
		let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
		guard let indexPathItem = self.infiniteMonthCollectionView.indexPathForItem(at: visiblePoint)?.item else { return }
		let newTitle = String(describing: Month.asArray[indexPathItem % 12]).capitalized
		setTitleFromScrollViewPaged(newTitle: newTitle)
	}
}

// MARK: Search Bar Delegates
extension _MainViewController: UISearchControllerDelegate {

	func updateSearchResults(for searchController: UISearchController) {

		self.viewModel.searchString = searchController.searchBar.text!
		infiniteMonthCollectionView.reloadData()
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		self.viewModel.searchString = searchText
	}
}


