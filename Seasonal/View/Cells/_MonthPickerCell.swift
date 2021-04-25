//
//  _MonthPickerCell.swift
//  Seasonal
//
//  Created by Clint Thomas on 13/4/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import UIKit

class _MonthPickerCell: UICollectionViewCell {

	@IBOutlet weak var monthLabel: UILabel!

	override func prepareForReuse() {
		super.prepareForReuse()

		for currentView in self.subviews {
			currentView.clearsContextBeforeDrawing = true
			currentView.removeFromSuperview()
		}
	}

	func updateViews(month: Month) {
		addConstraint(NSLayoutConstraint(item: monthLabel!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
		addConstraint(NSLayoutConstraint(item: monthLabel!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))

		monthLabel.text = String(describing: month).capitalized
		self.index(ofAccessibilityElement: self)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
	}
}
