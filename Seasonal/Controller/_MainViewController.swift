//
//  _MainViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 25/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import UIKit

// TODO: swift lint after deleting irrelevant files

class _MainViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating {

	var viewModel: _MainViewModel!
	//@IBOutlet weak var infiniteMonthCollectionView: InfiniteCollectionView!
	@IBOutlet weak var infiniteMonthCollectionView: UICollectionView!
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
		infiniteMonthCollectionView.delegate = self
		infiniteMonthCollectionView.dataSource = self
		infiniteMonthCollectionView.isPrefetchingEnabled = false
		setUpNavigationControllerView()
		setupMenuBar()
		setupCollectionView()
		self.title = viewModel.updateTitle()
	}

	// Init child viewModel & assign delegate between child and parent viewModel
	private func setupMenuBar() {
		menuBar.viewModel = .init(month: viewModel.month, season: nil, viewDisplayed: viewModel.viewDisplayed)
		menuBar.viewModel.delegate = viewModel.self
		menuBar.accessibilityIdentifier = "menuBar"
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
			infiniteMonthCollectionView.collectionViewLayout = flowLayout
		}
		infiniteMonthCollectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		infiniteMonthCollectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
	}

	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
	}

	// Scroll to correct month before view is presented
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		if viewModel.monthsProduce.count > 0 {
			let indexPath = IndexPath(item: (viewModel.month.rawValue), section: 0)
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
			return 14
		default:
			return 14
		}
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants._MonthTableCell, for: indexPath) as! _MonthTableCollectionViewCell
		// for my implementation of the infinite collectionView I need to change the subview cell tag
		// based on the indexPath
		cell.tag = (indexPath.item)
		cell.viewModel = viewModel
		cell.tableView.reloadData()
		return cell
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
		let pageFloat = (scrollView.contentOffset.x / scrollView.frame.size.width)
		let pageInt = Int(round(pageFloat))
		//onPageInt = pageInt + 1
		switch pageInt {
		case 0:
			//pageInt = 12
			infiniteMonthCollectionView.scrollToItem(at: [0, 12], at: .left, animated: false)
		case viewModel.monthsProduce.count - 1:
		//	pageInt = 0
			infiniteMonthCollectionView.scrollToItem(at: [0, 1], at: .right, animated: false)
		default:
			break
		}
		// this is the page currently displayed
		//let page = scrollView.contentOffset.x / scrollView.bounds.size.width
		if var updatedMonth = Month.init(rawValue: pageInt) {
			// update menubar before calling method for animation of month icon
			if viewModel.previousMonth != updatedMonth {
				if updatedMonth == Month.januaryOverflow {
					updatedMonth = Month.january
				} else if updatedMonth ==  Month.decemberOverflow {
					updatedMonth = Month.december
				}
				menuBar.monthIconCarouselAnimation(from: viewModel.month, to: updatedMonth)
				viewModel.previousMonth = updatedMonth
			}
			viewModel.month = updatedMonth
			let newTitle = String(describing: viewModel.month).capitalized
			// override the title because it can be wrong if not scrolled properly
			setTitleFromScrollViewPaged(newTitle: newTitle)
		}
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


