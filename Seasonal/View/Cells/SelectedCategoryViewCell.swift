//
//  SelectedCategoryViewCell.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/1/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

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

    func updateViews(produce: ProduceViewModel) {
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
        animateLikeButton(button: self.likeButton, selected: self.likeButton.isSelected)
        likeButtonDelegate?.likeButtonTapped(cell: self)
    }

    // MARK: Animations

    func animateLikeButton (button: UIButton, selected: Bool) {
        // this removed a bug where the button jumped if I pressed like then pressed unlike - boom jump to the left.
        button.translatesAutoresizingMaskIntoConstraints = true

        if selected == true {
            button.setImage(UIImage(named: "\(LIKED).png"), for: .normal)
            UIView.animate(withDuration: 0.2, animations: {() -> Void in
                button.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
            }, completion: { _ in
                UIView.animate(withDuration: 0.2, animations: {
                    button.transform = CGAffineTransform.identity.scaledBy(x: 1.12, y: 1.12)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.2, animations: {
                        button.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
                    })
                })
            })
        } else {
            button.setImage(UIImage(named: "\(LIKED).png"), for: .normal)
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
}

