//
//  Extension-UILabel.swift
//  Seasonal
//
//  Created by Clint Thomas on 1/6/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import UIKit

extension UILabel {

	func animatedWelcomeLabel(initialLabelText: String) {
		self.alpha = 0.0
		UIView.animate(withDuration: 0.9, animations: {() -> Void in
			self.text = initialLabelText
			self.alpha = 1
		}, completion: { _ in
			UIView.animate(withDuration: 2, animations: {() -> Void in
				self.alpha = 0.999
			}, completion: { _ in
				UIView.animate(withDuration: 2, animations: {() -> Void in
					self.alpha = 0.0
				}, completion: { _ in
					self.text = "Swipe between months and\n filter by category"
					UIView.animate(withDuration: 0.3, animations: {
						self.alpha = 1
					}, completion: { _ in
						UIView.animate(withDuration: 2, animations: {
							self.alpha = 0.999
						}, completion: { finished in
							UIView.animate(withDuration: 2, animations: {
								self.alpha = 0
							}, completion: { finished in
								if finished {
									self.animatedWelcomeLabel(initialLabelText: initialLabelText)
								}
							})
						})
					})
				})
			})
		})
	}
}
