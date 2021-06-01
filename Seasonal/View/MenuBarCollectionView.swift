//
//  MenuBar.swift
//  Seasonal
//
//  Created by Clint Thomas on 6/2/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit
import Foundation

class MenuBarCollectionView: UICollectionView {

	weak var coordinator: MainViewCoordinator?

	var viewModel: MenuBarViewModel!

	override func awakeFromNib() {
		super.awakeFromNib()
		setupView()
	}

	private func setupView() {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 5, height: self.frame.height)
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 0

		self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		self.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		self.collectionViewLayout = layout
		self.allowsMultipleSelection = false

		self.delegate = self
		self.dataSource = self
	}

	// Menu Bar Actions

	/// If menuBar is tapped at index 4, we need to animate the cells across to
	/// present the
	/// - Parameters:
	///   - index: index that was tapped
	func beginMenuBarAnimation(for index: Int) {
		switch index {
		case ViewDisplayed.ProduceCategory.all.rawValue:
			self.scrollToItem(at: IndexPath(row: 8, section: 0),
							  at: .right,
							  animated: true
			)
		case ViewDisplayed.ProduceCategory.cancelled.rawValue:
			self.scrollToItem(at: IndexPath(row: 0, section: 0),
							  at: .left,
							  animated: true
			)
		default:
			break
		}
	}

	func menuBarScrollFinished() {
		//
	}

	// MARK: Scrolling Month Animation
	// Only for MonthViewVC
	func monthIconCarouselAnimation(from previousMonth: Month, to monthToScrollTo: Month) {
		let indexPath = IndexPath(item: 2, section: 0)

		if let cell = self.cellForItem(at: indexPath) as? MenuBarCollectionViewCell {
			if cell.isSelected == true {
				let originX = frame.origin.x
				// slide coordinates for moving icon
				var slideTo = cell.imageView.frame.origin.x - UIScreen.main.bounds.width / 5
				// jump icon back to the opposite side before sliding back into the cell.
				var jumpTo = cell.imageView.frame.origin.x + UIScreen.main.bounds.width / 5 * 2

				if previousMonth == Month.december && monthToScrollTo == Month.january {
					jumpTo = cell.imageView.frame.origin.x + UIScreen.main.bounds.width / 5 * 2
					slideTo = cell.imageView.frame.origin.x - UIScreen.main.bounds.width / 5
				} else if previousMonth == Month.january && monthToScrollTo == Month.december {
					slideTo = cell.imageView.frame.origin.x + UIScreen.main.bounds.width / 5
					jumpTo = cell.imageView.frame.origin.x - UIScreen.main.bounds.width / 5 * 2
					// if page slideTo left
				} else if previousMonth.rawValue > monthToScrollTo.rawValue {
					slideTo = cell.imageView.frame.origin.x + UIScreen.main.bounds.width / 5
					jumpTo = cell.imageView.frame.origin.x - UIScreen.main.bounds.width / 5 * 2
					// else page slideTo right
				} else if previousMonth.rawValue < monthToScrollTo.rawValue {
					slideTo = cell.imageView.frame.origin.x - UIScreen.main.bounds.width / 5
					jumpTo = cell.imageView.frame.origin.x + UIScreen.main.bounds.width / 5 * 2
				}
				// slide icon
				UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
					cell.imageView.frame = CGRect(x: slideTo, y: cell.imageView.frame.origin.y, width: cell.imageView.frame.width, height: cell.imageView.frame.height)
				}, completion: { _ in
					// jump across
					cell.imageView.frame = CGRect(x: jumpTo, y: cell.imageView.frame.origin.y, width: cell.imageView.frame.width, height: cell.imageView.frame.height)
					cell.imageView.image = self.findNextMonthImage(month: monthToScrollTo)
					// slide in
					UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
						cell.imageView.frame = CGRect(x: originX + 15, y: cell.imageView.frame.origin.y, width: cell.imageView.frame.width, height: cell.imageView.frame.height)
					})
				})
			}
		}
	}

	/// This determines which image to show in the menu bar
	/// - Parameter categoryDisplayed: if category is tapped then display 'All' label, if cancel is tapped display 'Categories'
	func updateCategoryIcon(categoryDisplayed: Bool) {
		let indexPath = IndexPath(item: ViewDisplayed.ProduceCategory.all.rawValue, section: 0)
		if categoryDisplayed {
			viewModel.menuBarCells[indexPath.row].imageName = MenuBarModel.categories.imageName()
		} else {
			viewModel.menuBarCells[indexPath.row].imageName = MenuBarModel.altLabel.imageName()
		}
		self.reloadData()
	}

	// MARK: Delegate
//
//	private func updateMenuBarDelegate(indexPath: Int) {
//
//		var indexPathToScrollTo = IndexPath(row: 8, section: 0)
//		if indexPath == ViewDisplayed.ProduceFilter.cancelled.menuBarIndex() {
//			indexPathToScrollTo = IndexPath(row: 0, section: 0)
//		}
//
//		menuBarSelectedDelegate?.menuBarTapped(index: indexPath, indexToScrollTo: indexPathToScrollTo)
//	}

	func findNextMonthImage(month: Month) -> UIImage {
		if let monthImage = UIImage(named: month.calendarImageName) {
			return monthImage.withRenderingMode(.alwaysTemplate)
		}
		return UIImage()
	}

	// After selecting a month from the MonthPickerViewController, this will update the icon
	// to the current month
	func updateMonthIconImage(to month: Month) {
		let indexPath = IndexPath(item: ViewDisplayed.months.rawValue, section: 0)
		viewModel.menuBarCells[indexPath.row].imageName = month.calendarImageName
		self.reloadData()
	}
}

// MARK: CollectionView

extension MenuBarCollectionView: UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView, collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let height = 100
		return CGSize(width: collectionView.bounds.size.width, height: CGFloat(height))
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return viewModel.menuBarCells.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		self.layoutIfNeeded()

		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.MenuBarCell, for: indexPath) as? MenuBarCollectionViewCell {
			cell.updateViews(imageName: viewModel.menuBarCells[indexPath.row].imageName,
							 constraints: viewModel.menuBarCells[indexPath.row].constraints,
							 selected: viewModel.menuBarCells[indexPath.row].isSelected)

			if cell.isSelected {
				cell.isUserInteractionEnabled = false
			} else {
				cell.isUserInteractionEnabled = true
			}

			#if DEBUG
			if CommandLine.arguments.contains("enable-testing") {
				if indexPath == [0, 8] {
					cell.accessibilityIdentifier = "cancelCell"
				}
			}
			#endif

			return cell
		}
		return MenuBarCollectionViewCell()
	}
}

extension MenuBarCollectionView: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		viewModel.menuBarTapped(at: indexPath.item)
		beginMenuBarAnimation(for: indexPath.item)
		if indexPath.item == ViewDisplayed.ProduceCategory.all.rawValue {
			updateCategoryIcon(categoryDisplayed: false)
		} else if indexPath.item == ViewDisplayed.ProduceCategory.cancelled.rawValue {
			updateCategoryIcon(categoryDisplayed: true)
		}
		self.reloadData()
	}
}

extension MenuBarCollectionView: UICollectionViewDelegateFlowLayout {

	func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		if viewModel.selectedCategory == ViewDisplayed.ProduceCategory.cancelled {
			viewModel.categoryWasCancelledAnimationFinished()
			self.reloadData()
		}
	}
}
