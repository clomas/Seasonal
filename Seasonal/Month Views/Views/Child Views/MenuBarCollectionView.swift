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

	var viewModel: MenuBarViewModel?

	override func awakeFromNib() {
		super.awakeFromNib()

		setupView()
	}

	private func setupView() {
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 5, height: frame.height)
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 0

		contentInset = .allZero
		scrollIndicatorInsets = .allZero
		collectionViewLayout = layout
		allowsMultipleSelection = false

		delegate = self
		dataSource = self
	}

	// Menu Bar Actions

	/// If menuBar is tapped at index 4, we need to animate the cells across to
	/// present the
	/// - Parameters:
	///   - index: index that was tapped
	func beginMenuBarAnimation(for index: Int) {
		switch index {
		case ViewDisplayed.ProduceCategory.all.rawValue:
			scrollToItem(at: IndexPath(row: 8, section: 0), at: .right, animated: true)
		case ViewDisplayed.ProduceCategory.cancelled.rawValue:
			scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
		default:
			break
		}
	}

	// MARK: Scrolling Month Animation

	func monthIconCarouselAnimation(from previousMonth: Month, to monthToScrollTo: Month) {
		let indexPath: IndexPath = IndexPath(item: 2, section: 0)

		if let cell: MenuBarCollectionViewCell = cellForItem(at: indexPath) as? MenuBarCollectionViewCell {

			let originX: CGFloat = frame.origin.x
			// slide coordinates for moving icon
			var slideTo: CGFloat = cell.imageView.frame.origin.x - UIScreen.main.bounds.width / 5
			// jump icon back to the opposite side before sliding back into the cell.
			var jumpTo: CGFloat = cell.imageView.frame.origin.x + UIScreen.main.bounds.width / 5 * 2

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

			}, completion: { [weak self] _ in
				// jump across
				cell.imageView.frame = CGRect(x: jumpTo,
											  y: cell.imageView.frame.origin.y,
											  width: cell.imageView.frame.width,
											  height: cell.imageView.frame.height
				)
				cell.imageView.image = self?.findNextMonthImage(month: monthToScrollTo)

				// slide in
				UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
					cell.imageView.frame = CGRect(x: originX + 15,
												  y: cell.imageView.frame.origin.y,
												  width: cell.imageView.frame.width,
												  height: cell.imageView.frame.height
					)
				})
			})

		}
	}

	func updateMenuBarFromNavigation(viewDisplayed: ViewDisplayed?, month: Month) {
		toggleSelectedCells(viewDisplayed: viewDisplayed)
		updateMonthIconImage(to: month)
	}

	func toggleSelectedCells(viewDisplayed: ViewDisplayed?) {
		let selectedIndexPath: IndexPath = IndexPath(viewDisplayed: viewDisplayed)

		if let menuBarCellCount: Int = viewModel?.menuBarCells.count {
			for index in 0..<menuBarCellCount {

				if selectedIndexPath.item == index {
					selectItem(at: selectedIndexPath, animated: false, scrollPosition: .top)
					collectionView(self, didSelectItemAt: selectedIndexPath)

				} else {
					deselectItem(at: IndexPath(item: index, section: 0), animated: false)
				}
			}
		}
	}

	// After selecting a month from the MonthPickerViewController, this will update the icon
	// to the current month
	private func updateMonthIconImage(to month: Month) {
		viewModel?.menuBarCells[IndexPath(viewDisplayed: .months).item].imageName = month.calendarImageName
		reloadData()
	}

	private func findNextMonthImage(month: Month) -> UIImage {
		if let monthImage: UIImage = UIImage(named: month.calendarImageName) {
			return monthImage.withRenderingMode(.alwaysTemplate)
		}
		return UIImage()
	}
}

// MARK: CollectionView

extension MenuBarCollectionView: UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView, collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let height: Int = 100

		return CGSize(width: collectionView.bounds.size.width, height: CGFloat(height))
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return viewModel?.menuBarCells.count ?? 0
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		layoutIfNeeded()

		// swiftlint:disable line_length
		if let cell: MenuBarCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.MenuBarCell, for: indexPath) as? MenuBarCollectionViewCell {

			cell.updateViews(viewModel: viewModel?.menuBarCells[indexPath.item])

			#if DEBUG
			if CommandLine.arguments.contains("enable-testing"), indexPath == [0, 8] {
				cell.accessibilityIdentifier = "cancelCell"
			}
			#endif
			return cell
		}

		return MenuBarCollectionViewCell()
	}
}

extension MenuBarCollectionView: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		viewModel?.menuBarWasTapped(at: indexPath.item)
		beginMenuBarAnimation(for: indexPath.item)

		reloadData()
	}
}

extension MenuBarCollectionView: UICollectionViewDelegateFlowLayout {
	// reload menuBar as images will need to update if it's scrolls
	// categories -> all / all -> categories
	func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		reloadData()
	}
}
