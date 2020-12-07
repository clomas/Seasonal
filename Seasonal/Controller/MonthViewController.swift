//
//  MonthViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/1/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit
import CoreData
import InfiniteLayout
import CoreLocation

enum MonthsViewMenuBar: Int, CaseIterable {

    case favourites
    case calendar
    case currentMonth
    case seasons
    case all
    case fruit
    case vegetables
    case herbs
    case cancel

    var altLabel: String {
        switch self {
        case .all:
            return ALL
        default:
            return CATEGORY
        }
    }

    func imageName(currentMonth: Month) -> String {
        switch self {
        case .favourites: return "\(FAVOURITES.lowercased()).png"
        case .calendar: return "\(MONTHS.lowercased()).png"
        case .currentMonth: return "cal_\(currentMonth.shortMonthName).png"
        case .seasons: return "\(SEASONS.lowercased()).png"
        case .all: return "\(ALLCATEGORIES.lowercased()).png"
        case .fruit: return "\(FRUIT.lowercased()).png"
        case .vegetables: return "\(VEGETABLES.lowercased()).png"
        case .herbs: return "\(HERBS.lowercased()).png"
        case .cancel: return "\(CANCEL.lowercased()).png"
        }
    }

    func callAsFunction() -> Int {
        return self.rawValue
    }
}

class MonthViewController: UIViewController, UIGestureRecognizerDelegate, UISearchResultsUpdating, UISearchBarDelegate, Storyboarded, MenuBarDelegate, LikeButtonDelegate {

    weak var coordinator: MainCoordinator?

    // callback for coordinator
    var navigationCallback: ((ViewDisplayed) -> Void)?

    var searchController = UISearchController(searchResultsController: nil)
    var searchString: String = ""

    @IBOutlet weak var inifiniteMonthCollectionView: InfiniteCollectionView!
    @IBOutlet weak var favouritesTableView: UITableView!
    @IBOutlet weak var nothingToShowLabel: UILabel!
    @IBOutlet weak var menuBar: MenuBar!
    var lastSelectedMenuItem: Int?
    let categoryButtonArr = [UIButton]()

    // View models
    var stateViewModel: AppStateViewModel!
    var viewModel: ProduceCellViewModel!
    var menuBarViewModel: MenuBarViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()

        viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.favouritesTableView.reloadData()
            }
        }
    }

    // MARK: Setup

    private func setUpView() {
        setUpMenuBar()
        self.inifiniteMonthCollectionView.delegate = self
        self.inifiniteMonthCollectionView.dataSource = self
        self.favouritesTableView.dataSource = self
        configureSearchController()
        setupCollectionView()
        favouritesTableView.isHidden = true
        setContextualTitle()
    }

    private func setUpMenuBar() {
        if stateViewModel != nil {
            lastSelectedMenuItem = stateViewModel.status.current.onPage.rawValue
            menuBar.menuBarSelectedDelegate = self
            menuBar.menuBarViewModel = .init()
            menuBar.menuBarViewModel.initMenuBar(selected: stateViewModel.status.onPage.rawValue, month: stateViewModel.status.month)
        }
    }

    func viewDidReappear() {
        setContextualTitle()
        inifiniteMonthCollectionView.scrollToItem(at: .init(row: stateViewModel.status.month.rawValue, section: 0),
                                             at: .centeredHorizontally,
                                             animated: true)

        menuBar.menuBarViewModel.selectDeselectCells(indexSelected: stateViewModel.status.onPage.rawValue)
        menuBar.reloadData()
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

    // Scroll to correct month before view is presented
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if viewModel.produceCellVMs.count > 0 {
            let indexPath = IndexPath(item: stateViewModel.status.month.rawValue, section: 0)
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

        if stateViewModel.status.onPage  == .favourites && favouritesTableView.numberOfRows(inSection: 0) == 0 {
            self.favouritesTableView.isHidden = true
            if self.searchString.count > 0 {
                nothingToShowLabel.text = "No Search Results"
            } else {
                nothingToShowLabel.text = "No Favourites"
            }
        } else {
            self.inifiniteMonthCollectionView.isHidden = false
        }
    }

    // MARK: MenuBar Tapped

    func menuBarTapped(index: Int, indexToScrollTo: IndexPath) {
        // update viewmodel selecting and deselecting cells.
        menuBar.menuBarViewModel.selectDeselectCells(indexSelected: index)

        let previousViewDisplayed = stateViewModel.status.onPage

        // update viewmodel
        if index <= ViewDisplayed.seasons.rawValue {
            stateViewModel.status.onPage = ViewDisplayed.init(rawValue: index)!
        } else {
            stateViewModel.status.filter = ViewDisplayed.ProduceFilter.init(rawValue: index)!
        }

        switch index {
        case ViewDisplayed.favourites.rawValue:
            favouritesOrMonthSelected(favouritesPage: true)
            hideTableIfEmpty()
        case ViewDisplayed.monthPicker.rawValue, ViewDisplayed.seasons.rawValue:
            // for navigating back
            if let navCallback = navigationCallback {
                navCallback(previousViewDisplayed)
            }
            // update menubar before segue for navigating back
            menuBar.menuBarViewModel.selectDeselectCells(indexSelected: previousViewDisplayed.rawValue)
        case ViewDisplayed.months.rawValue:
                favouritesOrMonthSelected(favouritesPage: false)
        case ViewDisplayed.ProduceFilter.all.rawValue...ViewDisplayed.ProduceFilter.cancelled.rawValue:
            switch index {
            case ViewDisplayed.ProduceFilter.all.rawValue:
                menuBar.scrollToItem(at: indexToScrollTo, at: .right, animated: true)
            case ViewDisplayed.ProduceFilter.cancelled.rawValue:
                menuBar.scrollToItem(at: indexToScrollTo, at: .left, animated: true)
            default: break
            }
        default: break
        }

        let indexPath = IndexPath(row: stateViewModel.status.month.rawValue, section: 0)
        self.inifiniteMonthCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        self.inifiniteMonthCollectionView.reloadData()
        setContextualTitle()
    }

    // detect the end of scrolling animation before selecting cell
    func menuBarScrollFinished() {
        if stateViewModel.status.filter == .cancelled {
            menuBar.menuBarViewModel.menuBarCells[stateViewModel.status.onPage.rawValue].isSelected = true
            menuBar.reloadData()
        }
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

        if stateViewModel.status.onPage == .favourites {
            titleString = FAVOURITES
        } else if stateViewModel.status.onPage == .months {
            titleString = String(describing: stateViewModel.status.month).capitalized
        }

        switch stateViewModel.status.current.filter {
        case .cancelled, .all:
            self.title = titleString
        case .fruit, .vegetables, .herbs:
            self.title = "\(stateViewModel.status.current.filter.asString.capitalized) in \(titleString)"
        }
    }

    // MARK: Months or Favourites to show

    private func favouritesOrMonthSelected(favouritesPage: Bool) {
        if favouritesPage == true {
            self.favouritesTableView.reloadData()
            self.inifiniteMonthCollectionView.isHidden = true
            self.favouritesTableView.isHidden = false
        } else {
            self.inifiniteMonthCollectionView.reloadData()
            self.inifiniteMonthCollectionView.isHidden = false
            self.favouritesTableView.isHidden = true
        }
    }

    // MARK: Buttons

    func likeButtonTapped(cell: SelectedCategoryViewCell) {

        if let id = cell.id {
            viewModel.likedDatabaseHandler(id: id, liked: cell.likeButton.isSelected)
        }
        
        if let indexPath = self.favouritesTableView.indexPath(for: cell) {
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.favouritesTableView.beginUpdates()
                self.favouritesTableView.deleteRows(at: [indexPath], with: .right)
                self.favouritesTableView.endUpdates()
                self.hideTableIfEmpty()
            })
        }
    }

    @IBAction func inforButtonTapped(_ sender: Any) {
        let infoVC = InfoCardVC.instantiate()
        infoVC.state = stateViewModel.status.location
        infoVC.modalPresentationStyle = .popover
        present(infoVC, animated: true, completion: nil)
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


// MARK: Favourites Tableview

extension MonthViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.findFavourites(searchString: self.searchString, filter: self.stateViewModel.status.current.filter).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SELECTEDCATEGORYVIEWCELL) as? SelectedCategoryViewCell {
            var produce: ProduceViewModel
            produce = viewModel.findFavourites(searchString: self.searchString, filter: self.stateViewModel.status.current.filter)[indexPath.row]

            guard let image = UIImage(named: produce.imageName) else { return UITableViewCell() }

            cell.tag = produce.id
            cell.foodLabel.text = produce.produceName
            cell.foodImage.image = image
            cell.likeButton.isSelected = true
            cell.backgroundColor = UIColor.tableViewCell.tint
            cell.updateViews(produce: produce)
            cell.likeButtonDelegate = self
            return cell

        } else {
            return SelectedCategoryViewCell()
        }
    }
}

// MARK: Infinite Collection View Code

extension MonthViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        switch stateViewModel.status.onPage {
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
        cell.viewModel = viewModel
        cell.stateViewModel = stateViewModel
        cell.collectionReloadData()
        return cell
    }
}

extension MonthViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
}

extension MonthViewController: UICollectionViewDelegateFlowLayout {
    
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
        let month = Month.init(rawValue: (Int(page) % 12))

        menuBar.determineCoordinatesForAnimations(monthToScrollTo: month ?? .december,
                                                  previousMonth: stateViewModel.status.month)

        if stateViewModel.status.month != month {
            stateViewModel.status.month = month ?? .december
        }

        // override the title because it can be wrong if not scrolled properly        let monthSelectedIndex = indexPa
        var visibleRect = CGRect()
        visibleRect.origin = inifiniteMonthCollectionView.contentOffset
        visibleRect.size = inifiniteMonthCollectionView.bounds.size

        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPathItem = self.inifiniteMonthCollectionView.indexPathForItem(at: visiblePoint)?.item else { return }
        let newTitle = String(describing: Month.asArray[indexPathItem % 12]).capitalized

        stateViewModel.status.month = Month.asArray[indexPathItem % 12]
        menuBar.currentMonth = stateViewModel.status.month
        setTitleFromScrollViewPaged(newTitle: newTitle)
    }
}

// MARK: Search Bar Delegates
extension MonthViewController: UISearchControllerDelegate {

    func test() {
        searchString = ""
    }

    func updateSearchResults(for searchController: UISearchController) {

        self.searchString = searchController.searchBar.text!
        inifiniteMonthCollectionView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchString = searchText
    }

}

