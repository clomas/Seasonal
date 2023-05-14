//
//  MainViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 25/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating {

	@IBOutlet weak var infiniteMonthCollectionView: UICollectionView!
	@IBOutlet weak var menuBar: MenuBarCollectionView!

	var viewModel: MainViewModel!
	var searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
		setUpView()

		viewModel.reloadTableView = { [weak self] in
			self?.reloadAndScrollToSelectedViewIndex()
		}
		// Called from MonthPickerViewController to update -
		// month icon,
		// month in the table view
		// navigation bar title
		viewModel.updateMenuBar = { [weak self] in
			self?.menuBarNeedsUpdate()
		}
    }

	private func setUpView() {
		setUpNavigationControllerView()
		setupMenuBar()
		setupCollectionView()

		title = viewModel.updateTitle()
	}

	// Init child viewModel & assign delegate between child and parent viewModel
	private func setupMenuBar() {
		menuBar.viewModel = .init(month: viewModel.monthToDisplay, viewDisplayed: .currentMonth)
		menuBar.viewModel?.delegate = viewModel.self

		menuBar.toggleSelectedCells(viewDisplayed: viewModel.viewDisplayed)
		menuBar.accessibilityIdentifier = "menuBar"
	}

	private func reloadAndScrollToSelectedViewIndex() {
		let indexToScrollTo: Int = viewModel.viewDisplayed == .favourites ? 0 : viewModel.monthToDisplay.rawValue
		infiniteMonthCollectionView.reloadData()
		infiniteMonthCollectionView.scrollToItem(at: IndexPath(row: indexToScrollTo, section: 0),
												 at: .centeredHorizontally,
												 animated: false)
		title = viewModel.updateTitle()
	}

	private func menuBarNeedsUpdate() {
		menuBar.updateMenuBarFromNavigation(viewDisplayed: viewModel.viewDisplayed,
											month: viewModel.monthToDisplay
		)
	}

	private func setupCollectionView() {
		infiniteMonthCollectionView.delegate = self
		infiniteMonthCollectionView.dataSource = self
		infiniteMonthCollectionView.isPrefetchingEnabled = false

		if let flowLayout = infiniteMonthCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
			flowLayout.scrollDirection = .horizontal
			flowLayout.minimumLineSpacing = 0
			infiniteMonthCollectionView.collectionViewLayout = flowLayout
		}
		infiniteMonthCollectionView?.contentInset = UIEdgeInsets.allZero
		infiniteMonthCollectionView?.scrollIndicatorInsets = .allZero
	}

	override func viewWillAppear(_ animated: Bool) {
		infiniteMonthCollectionView.reloadData()
		navigationController?.setNavigationBarHidden(false, animated: animated)
	}

	// Scroll to correct month before view is presented
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		if viewModel.allMonthsAndTheirProduce?.isEmpty == false && viewModel.viewDisplayed != .favourites {
			let indexPath = IndexPath(item: (viewModel.monthToDisplay.rawValue), section: 0)
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
// TODO: custom navigation controller
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
		self.navigationController?.navigationBar.barTintColor = UIColor.NavigationBar.tint
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		self.definesPresentationContext = true

		if #available(iOS 15, *) {
			let appearance = UINavigationBarAppearance()
			appearance.configureWithOpaqueBackground()
			appearance.backgroundColor = UIColor.NavigationBar.tint
			UINavigationBar.appearance().standardAppearance = appearance
			UINavigationBar.appearance().scrollEdgeAppearance = appearance
		}
	}
}

// MARK: Infinite Collection View Data / Delegate

extension MainViewController: UICollectionViewDataSource {

	private var favouritesNumberOfItems: Int { 2 }
	private var infiniteMonthsNumberOfItems: Int { 14 }

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch viewModel.viewDisplayed {
		case .favourites:
			infiniteMonthCollectionView.isScrollEnabled = false
			return favouritesNumberOfItems
		case .months:
			infiniteMonthCollectionView.isScrollEnabled = true
			return infiniteMonthsNumberOfItems
		default:
			return favouritesNumberOfItems
		}
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.MonthTableCell,
														 for: indexPath) as? MonthTableCollectionViewCell {
			// for my implementation of the infinite collectionView I need to change the subview cell tag
			// based on the indexPath
			cell.tag = indexPath.item

			#warning("check this then get rid of it")
			print("=== cell tag \(cell.tag)")

			cell.viewModel = viewModel
			cell.tableView.reloadData()
			return cell
		} else {
			return MonthTableCollectionViewCell()
		}
	}
}

// MARK: CollectionView Layout

extension MainViewController: UICollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return collectionView.frame.height
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return .allZero
	}

	// MARK: ScrollView did end decelerating

	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let pageFloat = (scrollView.contentOffset.x / scrollView.frame.size.width)
		let pageInt = Int(round(pageFloat))

		switch pageInt {
		case 0:
			infiniteMonthCollectionView.scrollToItem(at: [0, 12], at: .left, animated: false)
		case (viewModel.allMonthsAndTheirProduce?.count ?? 0) - 1:

			#warning("check this, add static var for count")
			print("=== viewModel.allMonthsAndTheirProduce?.count \(viewModel.allMonthsAndTheirProduce?.count)")

			infiniteMonthCollectionView.scrollToItem(at: [0, 1], at: .right, animated: false)
		default:
			break
		}
		// this is the page currently displayed
		// let page = scrollView.contentOffset.x / scrollView.bounds.size.width
		if var updatedMonth = Month.init(rawValue: pageInt) {
			// update menubar before calling method for animation of month icon
			if viewModel.previousMonth != updatedMonth {
				if updatedMonth == Month.januaryOverflow {
					updatedMonth = Month.january
				} else if updatedMonth ==  Month.decemberOverflow {
					updatedMonth = Month.december
				}
				menuBar.monthIconCarouselAnimation(from: viewModel.monthToDisplay, to: updatedMonth)
				viewModel.previousMonth = updatedMonth
			}
			viewModel.monthToDisplay = updatedMonth
			let newTitle = String(describing: viewModel.monthToDisplay).capitalized
			// override the title because it can be wrong if not scrolled properly
			setTitleFromScrollViewPaged(newTitle: newTitle)
		}
	}
}

// MARK: Search Bar Delegates
extension MainViewController: UISearchControllerDelegate {

	func updateSearchResults(for searchController: UISearchController) {
		self.viewModel.searchString = searchController.searchBar.text!
		infiniteMonthCollectionView.reloadData()
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		self.viewModel.searchString = searchText
	}
}

extension IndexPath {

	init(viewDisplayed: ViewDisplayed?) {
		self.init(row: viewDisplayed?.rawValue ?? 0, section: 0)
	}

	init(produceCategory: ViewDisplayed.ProduceCategory?) {
		self.init(row: produceCategory?.rawValue ?? 0, section: 0)
	}
//
//	init(month: Month) {
//		self.init(row: month.rawValue, section: 0)
//	}
}
