//
//  MonthTableCollectionViewCell.swift
//  Seasonal
//
//  Created by Clint Thomas on 26/3/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit

class MonthTableCollectionViewCell: UICollectionViewCell, LikeButtonDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nothingToShowLabel: UILabel!

	var viewModel: MainViewModel?

	private var numberOfRows: Int = 0

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

	func likeButtonWasTapped(cell: ProduceMonthInfoViewCell, viewDisplayed: ViewDisplayed) {
		if let id: Int = cell.id {
			UINotificationFeedbackGenerator().notificationOccurred(.success)
			viewModel?.likeToggle(id: id, liked: cell.likeButton.isSelected)

			if viewDisplayed == .favourites {
				if let indexPath: IndexPath = tableView.indexPath(for: cell) {
					DispatchQueue.main.asyncAfter(deadline: .now(), execute: { [weak self] in
						self?.deleteRow(at: indexPath)
					})
				}
			}
        }
    }

	private func deleteRow(at indexPath: IndexPath) {
		tableView.beginUpdates()
		tableView.deleteRows(at: [indexPath], with: .right)
		tableView.endUpdates()

		updateLabelBehindTableView()
	}

	/// Contextual label updating.
	/// numberOfRows is needed to keep track of row numbers, given the table has two functions
	/// favourites or months, the variable is updated in multiple places.
	private func updateLabelBehindTableView() {
		if numberOfRows > 0 {
			nothingToShowLabel.text = ""
		} else {

			if viewModel?.viewDisplayed == .favourites {
				nothingToShowLabel.text = "No Favourites Selected"
			}

			if viewModel?.searchString.isEmpty == false {
				nothingToShowLabel.text = "No Search Results"
				UINotificationFeedbackGenerator().notificationOccurred(.error)
			}
		}
    }
}

// MARK: Tableview

extension MonthTableCollectionViewCell: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		numberOfRows = viewModel?.numberOfRows ?? 0
		updateLabelBehindTableView()

		return numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell: ProduceMonthInfoViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.ProduceMonthInfoViewCell) as? ProduceMonthInfoViewCell,
		   let category: ViewDisplayed.ProduceCategory = viewModel?.category,
		   let thisMonthForProduceCell: Month = viewModel?.thisMonthForProduceCell,
		   let searchString: String = viewModel?.searchString {

            cell.likeButtonDelegate = self

			switch viewModel?.viewDisplayed {
			case .favourites:
				guard let produce: Produce = viewModel?.filterFavourites(by: viewModel?.searchString, category: category)[indexPath.row] else { return cell }

				cell.updateViews(produce: produce, monthNow: thisMonthForProduceCell, in: .favourites)
				return cell

			case .months:
				guard let produce: Produce = viewModel?.filter(by: searchString, of: category)[tag][indexPath.row] else { return cell }

				cell.updateViews(produce: produce, monthNow: thisMonthForProduceCell, in: .months)
				return cell

			default:
				return ProduceMonthInfoViewCell()
			}
        }

		return ProduceMonthInfoViewCell()
    }
}

extension MonthTableCollectionViewCell: UITableViewDelegate {

    private func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        tableView.reloadData()
    }
}
