//
//  _MonthPickerViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 13/4/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import UIKit

class _MonthPickerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout {

	weak var coordinator: _MainViewCoordinator?

	@IBOutlet weak var monthCollectionView: UICollectionView!

	var currentMonthSelected: Month?

	override func viewDidLoad() {
		super.viewDidLoad()
		setUpNavigationController()
		monthCollectionView.delegate = self
		monthCollectionView.dataSource = self
	}

	func setUpNavigationController() {
		self.navigationController?.interactivePopGestureRecognizer?.delegate = self
		self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		self.navigationController?.navigationBar.isTranslucent = false
		self.navigationItem.hidesBackButton = true
		self.navigationItem.leftBarButtonItem = nil
		self.navigationController?.navigationBar.barTintColor = UIColor.NavigationBar.tint
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return Month.allCases.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.SelectMonthCell, for: indexPath) as? MonthPickerCell {
			cell.updateViews(month: Month.asArray[indexPath.row])
			return cell
		} else {
			return MonthPickerCell()
		}
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		if let month = Month(rawValue: indexPath.row) {
			coordinator?.monthPickerFinished(display: month)
		}
		self.dismiss(animated: true, completion: nil)
//		monthSelectViewTapped?(Month.init(rawValue: indexPath.row)!)
	}

	// MARK: Collection View Sizing
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let yourWidth = collectionView.bounds.width / 2.0
		let yourHeight = collectionView.bounds.height / 6.0

		return CGSize(width: yourWidth, height: yourHeight)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets.zero
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
}
