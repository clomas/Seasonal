//
//  SelectedCategoryViewCell.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/1/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit

protocol SeasonsLikeButtonDelegate {
    func likeButtonTapped(cell: SeasonsTableViewCell)
}

class SeasonsTableViewCell: UITableViewCell {

    var likeButtonDelegate: SeasonsLikeButtonDelegate?

    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!

    var id: Int?
    
    func updateViews(produce: ProduceViewModel) {

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

            let likeImage = UIImage(named: "\(UNLIKED).png")
            let tintedImage = likeImage?.withRenderingMode(.alwaysTemplate)
            self.likeButton.setImage(tintedImage, for: .normal)
            self.likeButton.tintColor = UIColor.LikeButton.likeTint
            self.likeButton.isSelected = false
        } else {
            likeButton.setImage(UIImage(named: "\(LIKED).png"), for: .normal)
            self.likeButton.isSelected = true
        }
    }

    // MARK: Button

    @IBAction func likeButtonPressed(_ sender: Any) {
        self.likeButton.isSelected.toggle()
        animateLikeButton(button: self.likeButton, selected: self.likeButton.isSelected)
        likeButtonDelegate?.likeButtonTapped(cell: self)
    }

    // MARK: Animations

    func animateLikeButton (button: UIButton, selected: Bool) {

        // this removed a bug where the button jumped if I pressed like then pressed unlike - boom jump to the left.
        button.translatesAutoresizingMaskIntoConstraints = true

        if selected == true {
            button.setImage(UIImage(named:"\(LIKED).png"), for: .normal)
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
            button.setImage(UIImage(named:"\(LIKED).png"), for: .normal)
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
