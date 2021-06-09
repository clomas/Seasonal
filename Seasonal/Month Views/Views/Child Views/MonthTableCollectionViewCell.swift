//
//  MonthTableCollectionViewCell.swift
//  Seasonal
//
//  Created by Clint Thomas on 26/3/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit

class MonthTableCollectionViewCell: UICollectionViewCell, LikeButtonDelegate {

    var viewModel: MainViewModel!

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

	func likeButtonTapped(cell: ProduceMonthInfoViewCell, viewDisplayed: ViewDisplayed) {
        if let id = cell.id {
			viewModel.likeToggle(id: id, liked: cell.isSelected)
			if viewDisplayed == .favourites {
				if let indexPath = self.tableView.indexPath(for: cell) {
					DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
						self.tableView.beginUpdates()
						self.tableView.deleteRows(at: [indexPath], with: .right)
						self.tableView.endUpdates()
						self.hideTableIfEmpty()
					})
				}
			}
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
}

// MARK: Tableview

extension MonthTableCollectionViewCell: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		switch viewModel.viewDisplayed {
		case .favourites:
			numberOfRows = viewModel.filterFavourites(by: viewModel.searchString, category: viewModel.category).count
			hideTableIfEmpty()
			return numberOfRows
		case .months:
			numberOfRows = viewModel.filter(by: viewModel.searchString, of: viewModel.category)[self.tag].count
			hideTableIfEmpty()
			return numberOfRows
		default:
			return 0
		}
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ProduceMonthInfoViewCell) as? ProduceMonthInfoViewCell {
            cell.likeButtonDelegate = self
			switch viewModel.viewDisplayed {
			case .favourites:
				let produce = viewModel.filterFavourites(by: viewModel.searchString, category: viewModel.category)[indexPath.row]
				cell.updateViews(produce: produce, in: .favourites)
				return cell
			case .months:
				let produce = viewModel.filter(by: viewModel.searchString, of: viewModel.category)[self.tag][indexPath.row]
				cell.updateViews(produce: produce, in: .months)
//				// TODO: Month tables
//				if let monthTag = Month.init(rawValue: self.tag) {
//					cell.foodLabel.text = Month.init(rawValue: monthTag.rawValue)?.calendarImageName
//				}
				return cell
			default:
				return ProduceMonthInfoViewCell()
			}
        } else {
            return ProduceMonthInfoViewCell()
        }
    }
}

extension MonthTableCollectionViewCell: UITableViewDelegate {

    private func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        tableView.reloadData()
    }
}
