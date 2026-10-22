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

	var viewModel: MainViewModel?

	private var userIsDragging: Bool = false

	private var lastUserScrolledMonth: MonthOld?

	override func viewDidLoad() {
		super.viewDidLoad()
		setUpView()

		viewModel?.reloadTableView = { [weak self] in
			self?.reloadAndScrollToSelectedViewIndex()
		}

		// Called from MonthPickerViewController to update -
		// month icon,
		// month in the table view
		// navigation bar title
		viewModel?.updateMenuBar = { [weak self] in
			self?.lastUserScrolledMonth = self?.viewModel?.monthToDisplay
			self?.menuBarNeedsUpdate()
		}
	}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        infiniteMonthCollectionView.reloadData()
        navigationController?.setNavigationBarHidden(false, animated: animated)
        setupMenuBar()
    }

	private func setUpView() {
		setupNavigationControllerView()
		setupSearchController()
		tapViewDismissesKeyboard()
		setupMenuBar()
		setupCollectionView()

		title = viewModel?.navigationBarTitleString
	}

		// Init child viewModel & assign delegate between child and parent viewModel
	private func setupMenuBar() {
		guard let viewModel else { return }

		menuBar.viewModel = .init(month: viewModel.monthToDisplay, viewDisplayed: .currentMonth)
		menuBar.viewModel?.delegate = viewModel

		menuBar.toggleSelectedCells(viewDisplayed: viewModel.viewDisplayed)
		menuBar.accessibilityIdentifier = "menuBar"
	}

	private func reloadAndScrollToSelectedViewIndex() {
		if viewModel?.viewDisplayed == .favourites {
			UIView.performWithoutAnimation {
				infiniteMonthCollectionView.reloadData()
				infiniteMonthCollectionView.layoutIfNeeded()
				infiniteMonthCollectionView.setContentOffset(.zero, animated: false)
			}
			title = viewModel?.navigationBarTitleString
		} else {
			let indexToScrollTo: Int = viewModel?.monthToDisplay.rawValue ?? 0
			infiniteMonthCollectionView.reloadData()
			infiniteMonthCollectionView.layoutIfNeeded()
			scrollToItemUpdateTitle(indexToScrollTo)
		}
	}

	private func scrollToItemUpdateTitle(_ indexToScrollTo: Int) {
		if viewModel?.viewDisplayed == .favourites {
			title = viewModel?.navigationBarTitleString
			return
		}

		if let current = indexOfCenteredItem(), current == indexToScrollTo {
            // Already centered; just ensure the title is right
			setTitleFromScrollViewPaged(newTitle: viewModel?.navigationBarTitleString)
			return
		}

		CATransaction.begin()
		CATransaction.setCompletionBlock { [weak self] in
			self?.setTitleFromScrollViewPaged(newTitle: self?.viewModel?.navigationBarTitleString)
		}
		infiniteMonthCollectionView.reloadData()
		infiniteMonthCollectionView.layoutIfNeeded()
		infiniteMonthCollectionView.scrollToItem(at: IndexPath(item: indexToScrollTo, section: 0), at: .centeredHorizontally, animated: false)
		CATransaction.commit()
	}

	private func menuBarNeedsUpdate() {
		menuBar.updateMenuBarFromNavigation(viewDisplayed: viewModel?.viewDisplayed,
											month: viewModel?.monthToDisplay ?? .december
		)
	}

	private func setupCollectionView() {
		infiniteMonthCollectionView.delegate = self
		infiniteMonthCollectionView.dataSource = self
		infiniteMonthCollectionView.isPrefetchingEnabled = false

		if let flowLayout: UICollectionViewFlowLayout = infiniteMonthCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
			flowLayout.scrollDirection = .horizontal
			flowLayout.minimumLineSpacing = 0
			infiniteMonthCollectionView.collectionViewLayout = flowLayout
		}
		infiniteMonthCollectionView?.contentInset = UIEdgeInsets.allZero
		infiniteMonthCollectionView?.scrollIndicatorInsets = .allZero
	}

	private func indexOfCenteredItem() -> Int? {
		let center = CGPoint(
			x: infiniteMonthCollectionView.contentOffset.x + infiniteMonthCollectionView.bounds.width/2,
			y: infiniteMonthCollectionView.bounds.height/2
		)
		return infiniteMonthCollectionView.indexPathForItem(at: center)?.item
	}

    // MARK: Title

    /// Scrollview Paging changes the title
    /// - Parameter newTitle: newTitle is the month determined from the index of the main tableView
    /// this only runs if the infiniteMonthCollectionView is visible, otherwise the heading is "Favourites"
	private func setTitleFromScrollViewPaged(newTitle: String?) {
		if viewModel?.viewDisplayed == .months, let newTitle: String = newTitle, newTitle.isEmpty == false {

			if (newTitle).isEmpty == false { // only proceed with a valid value for newTitle.
											 // CATransition code
				let titleAnimation: CATransition = CATransition()
				titleAnimation.duration = 0.5
				titleAnimation.type = CATransitionType.fade
				titleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                // this is a detail view controller, so we must grab the reference
                // to the parent view controller's navigation controller
                // then cycle through until we find the title labels.
				if let subviews: [UIView] = navigationController?.navigationBar.subviews {
					for navigationItem in subviews {
						for itemSubView in navigationItem.subviews {
							if let largeLabel: UILabel = itemSubView as? UILabel {
								largeLabel.layer.add(titleAnimation, forKey: "changeTitle")
							}
						}
					}
				}
				navigationItem.title = newTitle
			}
		}
	}

	@IBAction func infoButtonWasTapped(_ sender: Any) {
		viewModel?.infoButtonTapped()
	}

    // MARK: Search controller setup

	private func setupNavigationControllerView() {
		navigationController?.navigationBar.isTranslucent = false
		navigationController?.navigationBar.barTintColor = UIColor.NavigationBar.tint

		if #available(iOS 15, *) {
			let appearance: UINavigationBarAppearance = UINavigationBarAppearance()
			appearance.configureWithOpaqueBackground()
			appearance.backgroundColor = UIColor.NavigationBar.tint
			UINavigationBar.appearance().standardAppearance = appearance
			UINavigationBar.appearance().compactAppearance = appearance
			UINavigationBar.appearance().scrollEdgeAppearance = appearance
			UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
		}
	}

	private func setupSearchController() {
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
		definesPresentationContext = true
	}
}

// MARK: Infinite Collection View Data / Delegate

extension MainViewController: UICollectionViewDataSource {

	static private var favouritesNumberOfItems: Int = 2
	static private var infiniteMonthsNumberOfItems: Int = 14

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

		switch viewModel?.viewDisplayed {
		case .favourites:
			infiniteMonthCollectionView.isScrollEnabled = false
			return MainViewController.favouritesNumberOfItems
		case .months:
			infiniteMonthCollectionView.isScrollEnabled = true
			return MainViewController.infiniteMonthsNumberOfItems
		default:
			return MainViewController.favouritesNumberOfItems
		}
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell: MonthTableCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.MonthTableCell,
																					   for: indexPath) as? MonthTableCollectionViewCell {
			if viewModel?.viewDisplayed == .favourites {
				cell.tag = 0
			} else {
				cell.tag = indexPath.item
			}
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

	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		userIsDragging = true
	}

	// MARK: ScrollView did end decelerating

	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		guard userIsDragging else { return }
		defer { userIsDragging = false }
		guard viewModel?.viewDisplayed == .months else { return }

		let center = CGPoint(
			x: scrollView.contentOffset.x + scrollView.bounds.width/2,
			y: scrollView.bounds.height/2
		)
		guard let indexPath = infiniteMonthCollectionView.indexPathForItem(at: center) else { return }

		let pageInt = indexPath.item

		switch pageInt {
		case 0:
			infiniteMonthCollectionView.scrollToItem(at: [0, 12], at: .left, animated: false)
		case (viewModel?.allMonthsAndTheirProduceToDisplay?.count ?? 0) - 1:
			infiniteMonthCollectionView.scrollToItem(at: [0, 1], at: .right, animated: false)
		default:
			break
		}

        // this is the page currently displayed
        // let page = scrollView.contentOffset.x / scrollView.bounds.size.width
		if var updatedMonth: MonthOld = MonthOld(rawValue: pageInt) {
            // Map overflow indices to canonical months for comparison/animation
			if updatedMonth == .januaryOverflow { updatedMonth = .january }
			else if updatedMonth == .decemberOverflow { updatedMonth = .december }

            // Only react if the user actually moved to a different logical month
			guard updatedMonth != viewModel?.monthToDisplay else { return }
			guard updatedMonth != lastUserScrolledMonth else { return }

            // Update VM state based on the user scroll
			viewModel?.monthToDisplay = updatedMonth

            // Animate the month icon strictly on user scroll
			menuBar.monthIconCarouselAnimation(
				from: lastUserScrolledMonth ?? (viewModel?.previousMonth ?? .december),
				to: updatedMonth
			)

            // Track last user-scrolled month separate from VM so external updates don't trigger animation
			lastUserScrolledMonth = updatedMonth
			viewModel?.previousMonth = updatedMonth

            // Update the title for the newly visible month
			setTitleFromScrollViewPaged(newTitle: viewModel?.navigationBarTitleString)
		}
	}
}

// MARK: Search Bar Delegates

extension MainViewController: UISearchControllerDelegate {

	func updateSearchResults(for searchController: UISearchController) {
		viewModel?.filterProduce(by: searchController.searchBar.text)
		infiniteMonthCollectionView.reloadData()
	}
}
