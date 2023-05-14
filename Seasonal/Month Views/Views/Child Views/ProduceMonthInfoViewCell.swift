//
//  SelectedCategoryViewCell.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/1/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit

protocol LikeButtonDelegate: AnyObject {
	func likeButtonWasTapped(cell: ProduceMonthInfoViewCell, viewDisplayed: ViewDisplayed)
}

class ProduceMonthInfoViewCell: UITableViewCell {

    weak var likeButtonDelegate: LikeButtonDelegate?

    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!

	var viewDisplayed: ViewDisplayed?
	var currentMonth: Month?
    var id: Int?

    @IBOutlet var monthImages: [UIImageView] = []

	func updateViews(produce: Produce, monthNow: Month, in view: ViewDisplayed) {
		guard let image = UIImage(named: produce.imageName) else { return }

		id = produce.id
		currentMonth = monthNow
		viewDisplayed = view

        foodLabel.text = produce.produceName
        foodImage.image = image

        backgroundColor = UIColor.TableViewCell.tint

        if produce.liked == true {
			likeButton.setImage(UIImage(named: "\(Constants.liked).png"), for: .normal)
			likeButton.isSelected = true

        } else {
			let likeImage: UIImage? = UIImage(named: "\(Constants.unliked).png")
			let tintedImage: UIImage? = likeImage?.withRenderingMode(.alwaysTemplate)
			likeButton.setImage(tintedImage, for: .normal)
			likeButton.tintColor = UIColor.LikeButton.tint
			likeButton.isSelected = false
        }

        // find month
		var monthIndex: Int = 1

        for uiView in monthImages {
            if monthIndex == currentMonth?.rawValue {
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

    @IBAction func monthsLikeButtonWasTapped(_ sender: Any) {

		if viewDisplayed == .months {
			likeButton.animateLikeButton(selected: likeButton.isSelected)
			likeButtonDelegate?.likeButtonWasTapped(cell: self, viewDisplayed: .months)

		} else {
			likeButtonDelegate?.likeButtonWasTapped(cell: self, viewDisplayed: .favourites)
		}

		likeButton.isSelected.toggle()
    }
}
