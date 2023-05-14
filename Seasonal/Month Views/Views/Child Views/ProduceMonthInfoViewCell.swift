//
//  SelectedCategoryViewCell.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/1/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit

protocol LikeButtonDelegate: AnyObject {
	func likeButtonTapped(cell: ProduceMonthInfoViewCell, viewDisplayed: ViewDisplayed)
}

class ProduceMonthInfoViewCell: UITableViewCell {

    weak var likeButtonDelegate: LikeButtonDelegate?

    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!

	var viewDisplayed: ViewDisplayed?
	var currentMonth: Month?
    var id: Int?

    // Array of monthImages - https://stackoverflow.com/questions/24805180/swift-put-multiple-iboutlets-in-an-array
    @IBOutlet var monthImages: [UIImageView] = []

	func updateViews(produce: ProduceModel, currentMonth: Month, in view: ViewDisplayed) {
		self.id = produce.id
		self.currentMonth = currentMonth
		self.viewDisplayed = view

        foodLabel.text = produce.produceName
        guard let image = UIImage(named: produce.imageName) else { return }
        foodImage.image = image

        self.backgroundColor = UIColor.TableViewCell.tint

        if produce.liked == true {
			likeButton.setImage(UIImage(named: "\(Constants.liked).png"), for: .normal)
			self.likeButton.isSelected = true
        } else {
			let likeImage = UIImage(named: "\(Constants.unliked).png")
			let tintedImage = likeImage?.withRenderingMode(.alwaysTemplate)
			self.likeButton.setImage(tintedImage, for: .normal)
			self.likeButton.tintColor = UIColor.LikeButton.tint
			self.likeButton.isSelected = false
        }

        // find month
        var monthIndex = 1

        for uiView in monthImages {
            if monthIndex == currentMonth.rawValue {
                guard let image = UIImage(named: Month.asArray[monthIndex].imageName) else { return }
                uiView.image = image
            }
            if produce.months.contains(Month.asArray[monthIndex]) {
                uiView.tintColor = UIColor.MonthIcon.inSeasonTint
            } else {
                uiView.tintColor = UIColor.MonthIcon.nonSeasonTint
            }
            monthIndex += 1
        }
    }

    // MARK: Buttons

    @IBAction func monthsLikeButtonPressed(_ sender: Any) {
		if viewDisplayed == .months {
			self.likeButton.animateLikeButton(selected: self.likeButton.isSelected)
			likeButtonDelegate?.likeButtonTapped(cell: self, viewDisplayed: .months)
		} else {
			likeButtonDelegate?.likeButtonTapped(cell: self, viewDisplayed: .favourites)
		}
		self.likeButton.isSelected.toggle()
    }

    // MARK: Animations

    private func animateLikeButton (button: UIButton, selected: Bool) {

    }
}
