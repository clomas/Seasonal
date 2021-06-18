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
			UINotificationFeedbackGenerator().notificationOccurred(.success)
			viewModel.likeToggle(id: id, liked: cell.likeButton.isSelected)
			if viewDisplayed == .favourites {
				if let indexPath = self.tableView.indexPath(for: cell) {
					print(indexPath)
					DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
						self.tableView.beginUpdates()
						self.tableView.deleteRows(at: [indexPath], with: .right)
						self.tableView.endUpdates()
						self.updateLabelBehindTableView()
					})
				}
			}
        }
    }

	/// Contextual label updating.
	/// numberOfRows is needed to keep track of row numbers, given the table has two functions
	/// favourites or months, the variable is updated in multiple places.
	private func updateLabelBehindTableView() {
		if numberOfRows > 0 {
			nothingToShowLabel.text = ""
		} else {
			if viewModel.viewDisplayed == .favourites {
				nothingToShowLabel.text = "No Favourites Selected"
			}
			if viewModel.searchString.count > 0 {
				nothingToShowLabel.text = "No Search Results"
			}
			UINotificationFeedbackGenerator().notificationOccurred(.error)
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
			updateLabelBehindTableView()
			return numberOfRows
		case .months:
			numberOfRows = viewModel.filter(by: viewModel.searchString, of: viewModel.category)[self.tag].count
			updateLabelBehindTableView()
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
				cell.updateViews(produce: produce, currentMonth: viewModel.currentMonth, in: .favourites)
				return cell
			case .months:
				let produce = viewModel.filter(by: viewModel.searchString, of: viewModel.category)[self.tag][indexPath.row]
				cell.updateViews(produce: produce, currentMonth: viewModel.currentMonth, in: .months)
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
