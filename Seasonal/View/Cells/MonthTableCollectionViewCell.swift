//
//  MonthTableCollectionViewCell.swift
//  Seasonal
//
//  Created by Clint Thomas on 26/3/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit

class MonthTableCollectionViewCell: UICollectionViewCell, LikeButtonDelegate {

   // var stateViewModel: AppStateViewModel!
    var viewModel: _MonthsViewModel!
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

    private func setupView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: Like Button /////

    func likeButtonTapped(cell: SelectedCategoryViewCell) {
        if let id = cell.id {
            viewModel.likeToggle(id: id, liked: cell.likeButton.isSelected)
        }
    }

    private func hideTableIfEmpty() {
        nothingToShowLabel.text = ""

		// TODO: fix this if adding

//        if stateViewModel.status.onPage == .months && tableView.numberOfRows(inSection: 0) == 0 {
//            if self.searchString.count > 0 {
//                nothingToShowLabel.text = "No Search Results"
//                self.tableView.isHidden = true
//            }
//        } else {
//            self.tableView.isHidden = false
//        }
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
}

// MARK: Tableview

extension MonthTableCollectionViewCell: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return viewModel.filter(by: self.searchString,
                                                   of: viewModel.filter)[self.tag].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: SELECTEDCATEGORYVIEWCELL) as? SelectedCategoryViewCell {
            cell.likeButtonDelegate = self
            var produce: _ProduceModel
			produce = viewModel.filter(by: self.searchString , of: viewModel.filter)[self.tag][indexPath.row]
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


