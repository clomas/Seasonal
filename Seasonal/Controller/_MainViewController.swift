//
//  _MainViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 25/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import UIKit
import InfiniteLayout

class _MainViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, LikeButtonDelegate {

	var navigationCallback: ((ViewDisplayed) -> Void)?
	var searchController = UISearchController(searchResultsController: nil)
	var searchString: String = ""

	var lastSelectedMenuItem: Int?
	let categoryButtonArr = [UIButton]()

	@IBOutlet weak var inifiniteMonthCollectionView: InfiniteCollectionView!
	//@IBOutlet weak var favouritesTableView: UITableView!
	@IBOutlet weak var nothingToShowLabel: UILabel!
	//@IBOutlet weak var menuBar: MenuBar!

	// View models
	//var stateViewModel: AppStateViewModel!
	var monthsViewModel: _MonthsViewModel!
	var favouritesViewModel: _FavouritesViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
		setUpView()

//		monthsViewModel.reloadTableViewClosure = { [weak self] () in
//			DispatchQueue.main.async {
//				self?.favouritesTableView.reloadData()
//			}
//		}
    }

	private func setUpView() {
		self.inifiniteMonthCollectionView.delegate = self
		self.inifiniteMonthCollectionView.dataSource = self
//		self.favouritesTableView.dataSource = self
		configureSearchController()
		setupCollectionView()
//		favouritesTableView.isHidden = true
		setContextualTitle()

	}

	func viewDidReappear() {

		// TODO: set a command to check date again, reload

		setContextualTitle()

		inifiniteMonthCollectionView.scrollToItem(at: .init(row: monthsViewModel.month.rawValue, section: 0),
												  at: .centeredHorizontally,
												  animated: true)





		// remove menubar first then rebuild it



		


		//menuBar.menuBarViewModel.selectDeselectCells(indexSelected: monthsViewModel.appStatus.month.rawValue)
		//menuBar.reloadData()
	}
	override func viewDidDisappear(_ animated: Bool) {
		self.searchController.isActive = false
	}

	private func setupCollectionView() {
		if let flowLayout = inifiniteMonthCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
			flowLayout.scrollDirection = .horizontal
			flowLayout.minimumLineSpacing = 0
		}
		inifiniteMonthCollectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		inifiniteMonthCollectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		inifiniteMonthCollectionView?.isPagingEnabled = true
	}

	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
	}

	// Scroll to correct month before view is presented
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		if monthsViewModel.viewModel.count > 0 {
			let indexPath = IndexPath(item: monthsViewModel.month.rawValue, section: 0)
			inifiniteMonthCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
		}
	}

	// MARK: ScrollView Begins Decelerating

	// stops the jumpyness from scrolling when nothing is in the table
	func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		hideTableIfEmpty()
	}

	private func hideTableIfEmpty() {
		nothingToShowLabel.text = ""

//		if stateViewModel.status.onPage  == .favourites && favouritesTableView.numberOfRows(inSection: 0) == 0 {
//			self.favouritesTableView.isHidden = true
			if self.searchString.count > 0 {
				nothingToShowLabel.text = "No Search Results"
			} else {
				nothingToShowLabel.text = "No Favourites"
			}
//		} else {
//			self.inifiniteMonthCollectionView.isHidden = false
//		}
	}

	// MARK: Title

	private func setTitleFromScrollViewPaged(newTitle: String) {
		if inifiniteMonthCollectionView.isHidden == false {
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

	private func setContextualTitle() {
		var titleString = ""

		//if stateViewModel.status.onPage == .favourites {
		//	titleString = FAVOURITES
		//} else if stateViewModel.status.onPage == .months {
		titleString = String(describing: monthsViewModel.month).capitalized
		//}

//		switch stateViewModel.status.current.filter {
//		case .cancelled, .all:
			self.title = titleString
//		case .fruit, .vegetables, .herbs:
//			self.title = "\(stateViewModel.status.current.filter.asString.capitalized) in \(titleString)"
//		}
	}

	// MARK: Months or Favourites to show

	private func favouritesOrMonthSelected(favouritesPage: Bool) {
		if favouritesPage == true {
//			self.favouritesTableView.reloadData()
			self.inifiniteMonthCollectionView.isHidden = true
//			self.favouritesTableView.isHidden = false
		} else {
			self.inifiniteMonthCollectionView.reloadData()
			self.inifiniteMonthCollectionView.isHidden = false
//			self.favouritesTableView.isHidden = true
		}
	}

	// MARK: Buttons

	func likeButtonTapped(cell: SelectedCategoryViewCell) {

		if let id = cell.id {
			monthsViewModel.likeToggle(id: id, liked: cell.likeButton.isSelected)
		}
//
//		if let indexPath = self.favouritesTableView.indexPath(for: cell) {
//			DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
//				self.favouritesTableView.beginUpdates()
//				self.favouritesTableView.deleteRows(at: [indexPath], with: .right)
//				self.favouritesTableView.endUpdates()
//				self.hideTableIfEmpty()
//			})
//		}
	}

	@IBAction func inforButtonTapped(_ sender: Any) {
//		let infoVC = InfoCardVC.instantiate()
//		infoVC.state = stateViewModel.status.location
//		infoVC.modalPresentationStyle = .popover
//		present(infoVC, animated: true, completion: nil)
	}

	// MARK: Search controller setup

	private func configureSearchController() {

		nothingToShowLabel.text = ""
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
		self.searchController.hidesNavigationBarDuringPresentation = false
		self.definesPresentationContext = true
	}
}


// MARK: Infinite Collection View Code

extension _MainViewController: UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

		switch monthsViewModel.viewDisplayed {
		case .favourites:
			return 1
		case .months:
			return 12
		default:
			return 1
		}
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SCROLLINGCOLLECTIONVIEWCELL, for: indexPath) as! MonthTableCollectionViewCell
		cell.searchString = self.searchString
		cell.tag = (indexPath.item % 12)
		cell.viewModel = monthsViewModel
		cell.collectionReloadData()
		return cell
	}
}

extension _MainViewController: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
	}
}

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

	// MARK: scrollview

	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

		// this is the page currently displayed
		let page = scrollView.contentOffset.x / scrollView.bounds.size.width
		let updatedMonth = Month.init(rawValue: (Int(page) % 12))

		if let month = updatedMonth {
//			menuBar.determineCoordinatesForAnimations(monthToScrollTo: month,
//													  previousMonth: monthsViewModel.appStatus.month)
			monthsViewModel.month = month
		}



		// override the title because it can be wrong if not scrolled properly        let monthSelectedIndex = indexPa
		var visibleRect = CGRect()
		visibleRect.origin = inifiniteMonthCollectionView.contentOffset
		visibleRect.size = inifiniteMonthCollectionView.bounds.size

		let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
		guard let indexPathItem = self.inifiniteMonthCollectionView.indexPathForItem(at: visiblePoint)?.item else { return }
		let newTitle = String(describing: Month.asArray[indexPathItem % 12]).capitalized

		// TODO: I dont think I need this -
		//stateViewModel.status.month = Month.asArray[indexPathItem % 12]

		// TODO: update menubar viewmodel -
		// menuBar.currentMonth = stateViewModel.status.month

		setTitleFromScrollViewPaged(newTitle: newTitle)
	}
}

// MARK: Search Bar Delegates
extension _MainViewController: UISearchControllerDelegate {

	func updateSearchResults(for searchController: UISearchController) {

		self.searchString = searchController.searchBar.text!
		inifiniteMonthCollectionView.reloadData()
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		self.searchString = searchText
	}
}


