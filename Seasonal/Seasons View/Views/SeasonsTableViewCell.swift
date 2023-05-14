//
//  SelectedCategoryViewCell.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/1/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit

protocol SeasonsLikeButtonDelegate: AnyObject {
    func likeButtonWasTapped(cell: SeasonsTableViewCell)
}

class SeasonsTableViewCell: UITableViewCell {

    weak var likeButtonDelegate: SeasonsLikeButtonDelegate?

    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!

    var id: Int?

    func updateViews(produce: Produce) {
		guard let image = UIImage(named: produce.imageName) else { return }
		backgroundColor = UIColor.TableViewCell.tint

		id = produce.id
		foodLabel.text = produce.produceName
        foodImage.image = image

		likeButton.isSelected = produce.liked

        if produce.liked == false {
			let likeImage: UIImage? = UIImage(named: "\(Constants.unliked).png")
			let tintedImage: UIImage? = likeImage?.withRenderingMode(.alwaysTemplate)

            likeButton.setImage(tintedImage, for: .normal)
            likeButton.tintColor = UIColor.LikeButton.tint
            likeButton.isSelected = false
        } else {
			likeButton.setImage(UIImage(named: "\(Constants.liked).png"), for: .normal)
            likeButton.isSelected = true
        }
    }

    // MARK: Like Button

    @IBAction func likeButtonWasTapped(_ sender: Any) {
        likeButton.animateLikeButton(selected: likeButton.isSelected)
        likeButtonDelegate?.likeButtonWasTapped(cell: self)
		likeButton.isSelected.toggle()
    }
}
