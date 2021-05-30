//
//  SelectedCategoryViewCell.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/1/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit

protocol SeasonsLikeButtonDelegate: AnyObject {
    func likeButtonTapped(cell: SeasonsTableViewCell)
}

class SeasonsTableViewCell: UITableViewCell {

    weak var likeButtonDelegate: SeasonsLikeButtonDelegate?

    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!

    var id: Int?

    func updateViews(produce: ProduceModel) {

        self.id = produce.id
        guard let image = UIImage(named: produce.imageName) else { return }
        foodLabel.text = produce.produceName
        foodImage.image = image

        if produce.liked == true {
            self.likeButton.isSelected = true
        } else {
            self.likeButton.isSelected = false
        }

        self.backgroundColor = UIColor.tableViewCell.tint

        if produce.liked == false {
			let likeImage = UIImage(named: "\(Constants.unliked).png")
            let tintedImage = likeImage?.withRenderingMode(.alwaysTemplate)
            self.likeButton.setImage(tintedImage, for: .normal)
            self.likeButton.tintColor = UIColor.LikeButton.tint
            self.likeButton.isSelected = false
        } else {
			likeButton.setImage(UIImage(named: "\(Constants.liked).png"), for: .normal)
            self.likeButton.isSelected = true
        }
    }

    // MARK: Like Button

    @IBAction func likeButtonTapped(_ sender: Any) {
        self.likeButton.animateLikeButton(selected: self.likeButton.isSelected)
        likeButtonDelegate?.likeButtonTapped(cell: self)
		self.likeButton.isSelected.toggle()
    }
}
