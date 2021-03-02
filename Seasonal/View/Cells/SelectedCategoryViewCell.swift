//
//  SelectedCategoryViewCell.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/1/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

// TODO: fix alignment of December with like button. 

import UIKit

protocol LikeButtonDelegate {
    func likeButtonTapped(cell: SelectedCategoryViewCell)
}
//https://stackoverflow.com/questions/24805180/swift-put-multiple-iboutlets-in-an-array
class SelectedCategoryViewCell: UITableViewCell {

    var likeButtonDelegate: LikeButtonDelegate?

    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    var id: Int?

    // Array of monthImages - https://stackoverflow.com/questions/24805180/swift-put-multiple-iboutlets-in-an-array
    @IBOutlet var monthImages: [UIImageView] = []

    func updateViews(produce: _ProduceModel) {
        self.id = produce.id
        foodLabel.text = produce.produceName
        guard let image = UIImage(named: produce.imageName) else { return }
        foodImage.image = image

        if produce.liked == true {
            self.likeButton.isSelected = true
        } else {
            self.likeButton.isSelected = false
        }

        self.backgroundColor = UIColor.tableViewCell.tint

        if produce.liked == false {
            let likeImage = UIImage(named: "\(UNLIKED).png")
            let tintedImage = likeImage?.withRenderingMode(.alwaysTemplate)
            self.likeButton.setImage(tintedImage, for: .normal)
            self.likeButton.tintColor = UIColor.LikeButton.likeTint
            self.likeButton.isSelected = false
        } else {
            likeButton.setImage(UIImage(named: "\(LIKED).png"), for: .normal)
            self.likeButton.isSelected = true
        }

        // find month
        let dateIndex = DateHandler.instance.findMonthAndSeason()
        var monthIndex = 0

        // loop through images
        for uiView in monthImages {
            if monthIndex == dateIndex.0.rawValue {
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

    @IBAction func favouriteLikeButtonPressed(_ sender: Any) {
        self.likeButton.isSelected.toggle()
        likeButtonDelegate?.likeButtonTapped(cell: self)
    }

    @IBAction func monthsLikeButtonPressed(_ sender: Any) {
        self.likeButton.isSelected.toggle()
        self.likeButton.animateLikeButton(selected: self.likeButton.isSelected)
        likeButtonDelegate?.likeButtonTapped(cell: self)
    }

    // MARK: Animations

    private func animateLikeButton (button: UIButton, selected: Bool) {

    }
}


