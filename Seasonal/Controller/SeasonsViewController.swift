//
//  SeasonsViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 12/12/18.
//  Copyright © 2018 Clint Thomas. All rights reserved.
//

import UIKit

enum SeasonsViewMenuBar: Int, CaseIterable {

    case summer
    case autumn
    case winter
    case spring
    case all
    case fruit
    case vegetables
    case herbs
    case cancel

    var imageName: String {
        switch self {
        case .summer: return "\(Season.summer.asString.lowercased()).png"
        case .autumn: return "\(Season.autumn.asString.lowercased()).png"
        case .winter: return "\(Season.winter.asString.lowercased()).png"
        case .spring: return "\(Season.spring.asString.lowercased()).png"
        case .all: return "\(ALLCATEGORIES.lowercased()).png"
        case .fruit: return "\(FRUIT.lowercased()).png"
        case .vegetables: return "\(VEGETABLES.lowercased()).png"
        case .herbs: return "\(HERBS.lowercased()).png"
        case .cancel: return "\(CANCEL.lowercased()).png"
        }
    }
}

class SeasonsViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, UIGestureRecognizerDelegate, Storyboarded, SeasonsLikeButtonDelegate, MenuBarDelegate {

    weak var coordinator: MainCoordinator?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nothingToShowLabel: UILabel!
    @IBOutlet weak var menuBar: MenuBar!
    @IBOutlet weak var infoButton: UIBarButtonItem!
    @IBOutlet weak var seasonStack: UIStackView!

    var produceFilter: ViewDisplayed.ProduceFilter = .cancelled

    let categoryButtonArr = [UIButton]()

    var searchController = UISearchController(searchResultsController: nil)
    var searchString: String = ""

    // View models
    var stateViewModel: AppStateViewModel!
    var viewModel: ProduceCellViewModel!
    var menuBarViewModel: MenuBarCellViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    // MARK: Setup

    func setUpView() {
        setContextualTitle()
        setUpMenuBar()
        stateViewModel.status.current.onPage = .seasons
        configureSearchController()
        self.tableView.dataSource = self
    }

    func setUpMenuBar() {
        menuBar.menuBarSelectedDelegate = self
        menuBar.allowsMultipleSelection = false
        menuBar.menuBarViewModel = .init()
        menuBar.menuBarViewModel.initSeasonsMenuBar(selected: stateViewModel.status.season.rawValue)
    }

    override func viewDidAppear(_ animated: Bool) {
        navigationBarAnimations()
    }

   // MARK: Search Bar

    func configureSearchController () {
        nothingToShowLabel.text = ""
        let searchController = UISearchController(searchResultsController:  nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.isTranslucent = true
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        searchController.searchBar.tintColor = UIColor.NavigationBar.searchBarTint
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
        menuBar.menuBarViewModel.selectDeselectCells(indexSelected: index)

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
                menuBar.menuBarViewModel.menuBarCells[stateViewModel.status.filter.rawValue].isSelected = false
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
            menuBar.menuBarViewModel.menuBarCells[stateViewModel.status.season.rawValue].isSelected = true
            menuBar.reloadData()
        }
    }

    func setContextualTitle() {
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

    // MARK: Animations

    func animateLikeButton (button: UIButton, selected: Bool) {
        // this removed a bug where the button jumped if I pressed like then pressed unlike - boom jump to the left.
        button.translatesAutoresizingMaskIntoConstraints = true
        
        if selected == true {
            button.setImage(UIImage(named:"\(LIKED).png"), for: .normal)
            
            UIView.animate(withDuration: 0.2, animations: {() -> Void in
                button.transform = CGAffineTransform.identity.scaledBy(x: 0.6, y: 0.6)
            }, completion: { _ in
                UIView.animate(withDuration: 0.2, animations: {
                    button.transform = CGAffineTransform.identity.scaledBy(x: 1.2, y: 1.2)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.2, animations: {
                        button.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
                    })
                })
            })
        } else {
            button.setImage(UIImage(named:"\(LIKED).png"), for: .normal)
            button.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
                button.frame = CGRect(x: button.frame.origin.x , y: button.frame.origin.y , width: button.frame.width, height: button.frame.height)
            }, completion: { _ in
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
                    button.frame = CGRect(x: button.frame.origin.x + 100, y: button.frame.origin.y , width: button.frame.width, height: button.frame.height)
                }, completion: { _ in
                    
                    let image = UIImage(named: "\(UNLIKED).png")?.withRenderingMode(.alwaysTemplate)
                    button.setImage(image, for: .normal)
                    button.imageView?.tintColor = UIColor.LikeButton.likeTint

                    UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
                        button.frame = CGRect(x: button.frame.origin.x - 100, y: button.frame.origin.y , width: button.frame.width, height: button.frame.height)
                    })
                })
            })
        }
    }

    func animateButton(button: UIButton, title: String, colour: UIColor) {
        seasonStack.bringSubviewToFront(button)
        button.isSelected = true

        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            button.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.2)
        })
    }
    
    // MARK: NavBar setup /////
    func navigationBarAnimations() {
        let fadeTextAnimation = CATransition()
        fadeTextAnimation.duration = 2.5
        fadeTextAnimation.type = CATransitionType.fade

        let fadeNavBarAnimation = CATransition()
        fadeNavBarAnimation.duration = 2
        fadeNavBarAnimation.type = CATransitionType.fade

        self.navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: SEASONS)
        setContextualTitle()
        self.navigationController?.navigationBar.layer.add(fadeNavBarAnimation, forKey: SEASONS)
   
    }

    // MARK: Buttons
    func likeButtonTapped(cell: SeasonsTableViewCell) {
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
        self.navigationController?.popViewController(animated: true)
        
    }
}

// MARK: Table View
extension SeasonsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let season = stateViewModel.status.season
        return viewModel.filterBySelectedCategories(season: Season(rawValue: season.rawValue)!, searchString: searchString, filter: stateViewModel.status.filter).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let season = stateViewModel.status.season.rawValue
        if let cell = tableView.dequeueReusableCell(withIdentifier: SEASONSTABLEVIEWCELL) as? SeasonsTableViewCell {
            cell.likeButtonDelegate = self
            var produce: ProduceViewModel
            produce = viewModel.filterBySelectedCategories(season: Season(rawValue: season)!, searchString: searchString, filter: stateViewModel.status.filter)[indexPath.row]
            cell.updateViews(produce: produce)
            return cell
        } else {
            return SelectedCategoryViewCell()
        }
    }
}
