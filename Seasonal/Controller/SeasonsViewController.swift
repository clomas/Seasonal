//
//  SeasonsViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 12/12/18.
//  Copyright © 2018 Clint Thomas. All rights reserved.
//

import UIKit

class SeasonsViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, Storyboarded, _SeasonsLikeButtonDelegate, MenuBarDelegate {

    weak var coordinator: _MainViewCoordinator?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nothingToShowLabel: UILabel!
    @IBOutlet weak var menuBar: _MenuBar!
    @IBOutlet weak var infoButton: UIBarButtonItem!
    private var produceFilter: ViewDisplayed.ProduceFilter = .cancelled
    private var searchController = UISearchController(searchResultsController: nil)
    private var searchString: String = ""

    // View models
    weak var stateViewModel: AppStateViewModel!
    var viewModel: ProduceCellViewModel!
   // var menuBarViewModel: MenuBarCellViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    // MARK: Setup

    private func setUpView() {
        setContextualTitle()
        stateViewModel.status.current.onPage = .seasons
        configureSearchController()
        self.tableView.dataSource = self

		func setUpMenuBar() {
			//menuBar.menuBarSelectedDelegate = self
			menuBar.allowsMultipleSelection = false
			//menuBar.menuBarViewModel = .init(selected: stateViewModel.status.season.rawValue,
											 //month: Month(rawValue: stateViewModel.status.month.rawValue) ?? Month.december,
											 //viewDisplayed: ViewDisplayed.seasons
			//)
		}
		setUpMenuBar()
    }



    override func viewDidAppear(_ animated: Bool) {
        navigationBarAnimations()
    }

   // MARK: Search Bar

    private func configureSearchController () {
        nothingToShowLabel.text = ""
        let searchController = UISearchController(searchResultsController:  nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.isTranslucent = true
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        //searchController.searchBar.tintColor = UIColor.NavigationBar.searchBarTint
        navigationItem.hidesSearchBarWhenScrolling = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        
    }

    func updateSearchResults(for searchController: UISearchController) {
        searchString = searchController.searchBar.text ?? ""
    }

    // hides search bar after pressing back
    override func viewWillDisappear(_ animated: Bool) {
        self.searchController.searchBar.isHidden = true
    }
    
    func hideTableIfEmpty() {
        if tableView.numberOfRows(inSection: 0) == 0 {
            if searchString.count > 0 {
                nothingToShowLabel.text = "No Search Results"
            } else {
                nothingToShowLabel.text = "Nothing To Show"
            }
            self.tableView.isHidden = true
        } else {
            nothingToShowLabel.text = ""
            self.tableView.isHidden = false
        }
    }

    // MARK: Menu Bar

    func menuBarTapped(index: Int, indexToScrollTo: IndexPath) {
       // menuBar.menuBarViewModel.selectDeselectCells(indexSelected: index)

        switch index {
        case Season.summer.rawValue...Season.spring.rawValue:
            let season = Season.init(rawValue: index)
            stateViewModel.status.season = season ?? .summer
        case ViewDisplayed.ProduceFilter.all.rawValue...ViewDisplayed.ProduceFilter.cancelled.rawValue:
            stateViewModel.status.filter = ViewDisplayed.ProduceFilter.init(rawValue: index)!
            switch index {
            case ViewDisplayed.ProduceFilter.all.rawValue:
                menuBar.scrollToItem(at: indexToScrollTo, at: .right, animated: true)
            case ViewDisplayed.ProduceFilter.cancelled.rawValue:
                menuBar.scrollToItem(at: indexToScrollTo, at: .left, animated: true)
                //menuBar.menuBarViewModel.menuBarCells[stateViewModel.status.filter.rawValue].isSelected = false
            default: break
            }
        default: break
        }
        tableView.reloadData()
        menuBar.reloadData()
        self.setContextualTitle()
    }

    func menuBarScrollFinished() {
        if stateViewModel.status.filter == .cancelled {
            //menuBar.menuBarViewModel.menuBarCells[stateViewModel.status.season.rawValue].isSelected = true
            menuBar.reloadData()
        }
    }

    private func setContextualTitle() {
      var titleString = ""
      titleString = String(describing: stateViewModel.status.season).capitalized

      switch stateViewModel.status.current.filter {
      case .fruit, .vegetables, .herbs:
          titleString = "\(stateViewModel.status.current.filter.asString.capitalized) in \(titleString)"
      default:
          break
      }
      self.title = titleString
    }
    
    // MARK: NavBar setup /////
    private func navigationBarAnimations() {
        let fadeTextAnimation = CATransition()
        fadeTextAnimation.duration = 2.5
        fadeTextAnimation.type = CATransitionType.fade

        let fadeNavBarAnimation = CATransition()
        fadeNavBarAnimation.duration = 2
        fadeNavBarAnimation.type = CATransitionType.fade

		self.navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: Constants.Seasons)
        setContextualTitle()
       // self.navigationController?.navigationBar.layer.add(fadeNavBarAnimation, forKey: SEASONS)
   
    }

    // MARK: Buttons
    func likeButtonTapped(cell: _SeasonsTableViewCell) {
        if let id = cell.id {
            viewModel.likedDatabaseHandler(id: id, liked: cell.likeButton.isSelected)
        } 
    }


    @IBAction func infoButtonTapped(_ sender: Any) {
        let infoVC = InfoCardVC.instantiate()
        infoVC.state = stateViewModel.status.location
        infoVC.modalPresentationStyle = .popover
        present(infoVC, animated: true, completion: nil)
    }

	@IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
		self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
	}


//	@IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
//        self.navigationController?.popViewController(animated: true)
//
//    }


}

// MARK: Table View
extension SeasonsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let season = stateViewModel.status.season
        return viewModel.filterBySelectedCategories(season: Season(rawValue: season.rawValue)!, searchString: searchString, filter: stateViewModel.status.filter).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

//        let season = stateViewModel.status.season.rawValue
//		if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.SeasonsTableViewCell) as? _SeasonsTableViewCell {
//            cell.likeButtonDelegate = self
//            var produce: _ProduceModel
//            produce = viewModel.filterBySelectedCategories(season: Season(rawValue: season)!, searchString: searchString, filter: stateViewModel.status.filter)[indexPath.row]
//            cell.updateViews(produce: produce)
//            return cell
//        } else {
            return SelectedCategoryViewCell()
//        }
    }
}
