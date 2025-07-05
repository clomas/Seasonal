//
//  SelectMonthCollectionViewCell.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/3/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit

@IBDesignable

class MonthPickerCell: UICollectionViewCell {

    @IBOutlet weak var monthLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()

        for currentView in subviews {
			currentView.clearsContextBeforeDrawing = true
			currentView.removeFromSuperview()
        }
    }

    func updateViews(month: Month) {

		if let label: UILabel = monthLabel {
			addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
			addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))

			monthLabel.text = String(describing: month).capitalized
			index(ofAccessibilityElement: self)
		}
    }

    override func layoutSubviews() {
        super.layoutSubviews()

		contentView.frame = contentView.frame.inset(by: .allZero)
    }
}
