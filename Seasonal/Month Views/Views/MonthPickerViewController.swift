//
//  MonthPickerViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 13/4/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import UIKit

class MonthPickerViewController: UIViewController, UIGestureRecognizerDelegate {

	weak var coordinator: MainViewCoordinator?

	@IBOutlet weak var monthCollectionView: UICollectionView!

	override func viewDidLoad() {
		super.viewDidLoad()
		setUpNavigationController()
		monthCollectionView.delegate = self
		monthCollectionView.dataSource = self
		monthCollectionView.accessibilityIdentifier = "monthPicker"
	}

	func setUpNavigationController() {
		self.navigationController?.interactivePopGestureRecognizer?.delegate = self
		self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		self.navigationController?.navigationBar.isTranslucent = false
		self.navigationItem.hidesBackButton = true
		self.navigationItem.leftBarButtonItem = nil
		self.navigationController?.navigationBar.barTintColor = UIColor.NavigationBar.tint

		if #available(iOS 15, *) {
			let appearance = UINavigationBarAppearance()
			appearance.configureWithOpaqueBackground()
			appearance.backgroundColor = UIColor.NavigationBar.tint
			UINavigationBar.appearance().standardAppearance = appearance
			UINavigationBar.appearance().scrollEdgeAppearance = appearance
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		coordinator?.monthPickerFinished(display: nil)
	}
}

// MARK: UICollectionView Data Source

extension MonthPickerViewController: UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		// Less 2 given overflow Months
		return (Month.allCases.count - 2)
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.SelectMonthCell, for: indexPath) as? MonthPickerCell {
			// Plus 1 given overflow Months
			cell.updateViews(month: Month.asArray[(indexPath.row + 1)])
			return cell
		} else {
			return MonthPickerCell()
		}
	}
}

// MARK: UICollectionView Delegate Methods

extension MonthPickerViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		// Plus 1 given overflow Months
		if let month = Month(rawValue: (indexPath.row + 1)) {
			coordinator?.monthPickerFinished(display: month)
		}
		self.dismiss(animated: true, completion: nil)
	}

	// MARK: Collection View Sizing
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
		let cellWidth = collectionView.bounds.width / 2.0
		let cellHeight = collectionView.bounds.height / 6.0
		return CGSize(width: cellWidth, height: cellHeight)
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets.zero
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
}
