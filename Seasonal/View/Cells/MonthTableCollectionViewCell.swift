//
//  MonthTableCollectionViewCell.swift
//  Seasonal
//
//  Created by Clint Thomas on 26/3/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit



class MonthTableCollectionViewCell: UICollectionViewCell, LikeButtonDelegate {

    var stateViewModel: AppStateViewModel!
    var viewModel: ProduceCellViewModel!

    let searchController = UISearchController(searchResultsController: nil)
    var searchString: String = ""

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nothingToShowLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

    override func didMoveToSuperview() {
        setupView()
    }

    func setupView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: Like Button /////

    func likeButtonTapped(cell: SelectedCategoryViewCell) {
        if let id = cell.id {
            viewModel.likedDatabaseHandler(id: id, liked: cell.likeButton.isSelected)
        }
    }

    func hideTableIfEmpty() {
        nothingToShowLabel.text = ""

        if stateViewModel.status.onPage == .months && tableView.numberOfRows(inSection: 0) == 0 {
            if self.searchString.count > 0 {
                nothingToShowLabel.text = "No Search Results"
                self.tableView.isHidden = true
            }
        } else {
            self.tableView.isHidden = false
        }
    }

    // this is called from cell update on parent
    func collectionReloadData() {
        self.tableView.reloadData()
        hideTableIfEmpty()
    }
    
    // this resolves the green flash when horizontally scrolling with no search results
    @objc func alertScrollViewPaged(_ notification: Notification) {
        self.tableView.reloadData()

        if self.tableView.numberOfRows(inSection: 0) != 0 {
            self.tableView.scrollToRow(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: UITableView.ScrollPosition.top, animated: false)
        }
    }
    
    // MARK: Animation
    
    func animateLikeButton (button: UIButton, selected: Bool) {
        // this removed a bug where the button jumped if I pressed like then pressed unlike - boom jump to the left.
        button.translatesAutoresizingMaskIntoConstraints = true
        
        if selected == true {
            button.setImage(UIImage(named: "\(LIKED).png"), for: .normal)
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
            button.setImage(UIImage(named: "\(LIKED).png"), for: .normal)
            button.layoutIfNeeded()
            UIView.animate(withDuration: 0, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
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
}

// MARK: Tableview

extension MonthTableCollectionViewCell: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filterMonthCellByCategory(searchString: self.searchString,
                                                   filter: stateViewModel.status.filter)[self.tag].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: SELECTEDCATEGORYVIEWCELL) as? SelectedCategoryViewCell {
            cell.likeButtonDelegate = self
            var produce: ProduceViewModel
            produce = viewModel.filterMonthCellByCategory(searchString: self.searchString , filter: stateViewModel.status.filter)[self.tag][indexPath.row]
            cell.updateViews(produce: produce)
            return cell
        } else {
            return SelectedCategoryViewCell()
        }
    }
}

extension MonthTableCollectionViewCell: UITableViewDelegate {

    private func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        tableView.reloadData()
    }
}


