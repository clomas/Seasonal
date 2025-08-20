//
//  Extension-UIButton.swift
//  Seasonal
//
//  Created by Clint Thomas on 29/4/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//
// For like button animations

import UIKit

extension UIButton {

	// Button Animations
	func animateLikeButton(selected: Bool) {
		// this removed a bug where the button jumped if I tapped like then tapped unlike - boom jump to the left.
		translatesAutoresizingMaskIntoConstraints = true

		// current state before toggle is false
		if selected == false {
			setImage(UIImage(named: "\(Constants.liked).png"), for: .normal)
			UIView.animate(withDuration: 0.2, animations: {() -> Void in
				self.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)

			}, completion: { _ in
				UIView.animate(withDuration: 0.2, animations: {
					self.transform = CGAffineTransform.identity.scaledBy(x: 1.12, y: 1.12)

				}, completion: { _ in
					UIView.animate(withDuration: 0.2, animations: {
						self.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
					})
				})
			})
		} else {
			setImage(UIImage(named: "\(Constants.liked).png"), for: .normal)
			layoutIfNeeded()

			UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
				self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)

			}, completion: { _ in
				UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
					self.frame = CGRect(x: self.frame.origin.x + 100, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)

				}, completion: { _ in
					let image: UIImage? = UIImage(named: "\(Constants.unliked).png")?.withRenderingMode(.alwaysTemplate)
					self.setImage(image, for: .normal)
					self.imageView?.tintColor = UIColor.LikeButton.tint

					UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
						self.frame = CGRect(x: self.frame.origin.x - 100, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
					})
				})
			})
		}
	}
}
