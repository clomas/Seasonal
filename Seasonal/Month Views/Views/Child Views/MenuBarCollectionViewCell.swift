//
//  MenuBarCell.swift
//  Seasonal
//
//  Created by Clint Thomas on 13/4/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation
import UIKit

class MenuBarCollectionViewCell: UICollectionViewCell {

	var imageView = UIImageView()

	override var isSelected: Bool {
		didSet {
			imageView.tintColor = isSelected ? UIColor.MenuBar.selectedTint : UIColor.MenuBar.tint
			self.backgroundColor = isSelected ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
		}
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		for subView in self.subviews {
			subView.clearsContextBeforeDrawing = true
			subView.removeFromSuperview()
		}
	}

	func updateViews(imageName: String, constraints: (String, String), selected: Bool) {
		addSubview(imageView)
		self.imageView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
		imageView.tintColor = UIColor.MenuBar.tint
		self.backgroundColor = UIColor.NavigationBar.tint
		self.isSelected = selected
		addConstraintsWithFormat(constraints.0, views: imageView)
		addConstraintsWithFormat(constraints.1, views: imageView)
		addConstraint(NSLayoutConstraint(item: imageView,
										 attribute: .centerX,
										 relatedBy: .equal,
										 toItem: self,
										 attribute: .centerX,
										 multiplier: 1,
										 constant: 0))
		addConstraint(NSLayoutConstraint(item: imageView,
										 attribute: .centerY,
										 relatedBy: .equal,
										 toItem: self,
										 attribute: .centerY,
										 multiplier: 1.15,
										 constant: 0))

		self.index(ofAccessibilityElement: self)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
	}
}

// MARK: Constraints

extension UIView {

	func addConstraintsWithFormat(_ format: String, views: UIView...) {
		var viewsDictionary = [String: UIView]()
		for (index, view) in views.enumerated() {
			let key = "v\(index)"
			view.translatesAutoresizingMaskIntoConstraints = false
			viewsDictionary[key] = view
		}
		addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
	}
}
