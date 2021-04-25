//
//  _MonthTableCollectionViewCell.swift
//  Seasonal
//
//  Created by Clint Thomas on 26/3/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit

class _MonthTableCollectionViewCell: UICollectionViewCell, LikeButtonDelegate {

    var viewModel: _MainViewModel!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nothingToShowLabel: UILabel!
	var numberOfRows: Int = 0

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
		if viewModel.viewDisplayed == .favourites {
			nothingToShowLabel.text = "No Favourites Selected"
		}
		if viewModel.searchString.count > 0 {
			nothingToShowLabel.text = "No Search Results"
		}
		if numberOfRows != 0 {
			nothingToShowLabel.text = ""
		}
    }

    // this is called from cell update on parent
    func collectionReloadData() {
        self.tableView.reloadData()
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

extension _MonthTableCollectionViewCell: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch viewModel.viewDisplayed {
		case .favourites:
			numberOfRows = viewModel.filterFavourites(by: viewModel.searchString, filter: viewModel.filter).count
			hideTableIfEmpty()
			return numberOfRows
		case .months:
			numberOfRows = viewModel.filter(by: viewModel.searchString, of: viewModel.filter)[self.tag].count
			hideTableIfEmpty()
			return numberOfRows
		default:
			return 0
		}
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.SelectedCategoryCell) as? SelectedCategoryViewCell {
            cell.likeButtonDelegate = self
			switch viewModel.viewDisplayed {
			case .favourites:
				let produce = viewModel.filterFavourites(by: viewModel.searchString, filter: viewModel.filter)[indexPath.row]
				cell.updateViews(produce: produce)
				return cell
			case .months:
				let produce = viewModel.filter(by: viewModel.searchString , of: viewModel.filter)[self.tag][indexPath.row]
				cell.updateViews(produce: produce)
				return cell
			default:
				return SelectedCategoryViewCell()
			}
        } else {
            return SelectedCategoryViewCell()
        }
    }
}

extension _MonthTableCollectionViewCell: UITableViewDelegate {

    private func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        tableView.reloadData()
    }
}


