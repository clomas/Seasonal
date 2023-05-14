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

	let imageView = UIImageView()

	override func prepareForReuse() {
		super.prepareForReuse()

		for subView in self.subviews {
			subView.clearsContextBeforeDrawing = true
			subView.removeFromSuperview()
		}
	}

	func updateViews(viewModel: MenuBarCellModel?) {
		guard let menuBarViewModel: MenuBarCellModel = viewModel else { return }

		addSubview(imageView)
		imageView.image = UIImage(named: menuBarViewModel.imageName)?.withRenderingMode(.alwaysTemplate)

		if menuBarViewModel.isSelected == true {
			isUserInteractionEnabled = false
			imageView.tintColor = UIColor.MenuBar.selectedTint
		} else {
			isUserInteractionEnabled = true
			imageView.tintColor = UIColor.MenuBar.tint
		}
		backgroundColor = UIColor.NavigationBar.tint

		addConstraintsWithFormat(menuBarViewModel.constraints.0, views: imageView)
		addConstraintsWithFormat(menuBarViewModel.constraints.1, views: imageView)

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

		index(ofAccessibilityElement: self)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		contentView.frame = contentView.frame.inset(by: .allZero)
	}
}

// MARK: Constraints

private extension UIView {

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
