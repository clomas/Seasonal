//
//  Created by Clint Thomas on 6/2/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit
import Foundation

protocol MenuBarDelegate: AnyObject {
    func menuBarTapped(index: Int, indexToScrollTo: IndexPath)
    func menuBarScrollFinished()
}

class MenuBar: UICollectionView {

    weak var coordinator: MainCoordinator?
    weak var menuBarSelectedDelegate: MenuBarDelegate?
    var menuBarViewModel: MenuBarViewModel!
	private let cellId = Constants.MenuBarCell
    var currentMonth: Month?

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
        self.collectionViewLayout = layout;
        self.allowsMultipleSelection = false

        self.delegate = self
        self.dataSource = self
    }

	// MARK: Delegate

	private func updateMenuBarDelegate(indexPath: Int) {

		//var indexPathToScrollTo = IndexPath(row: 8, section: 0)
//		if indexPath == ViewDisplayed.ProduceFilter.cancelled.menuBarIndex() {
//			indexPathToScrollTo = IndexPath(row: 0, section: 0)
//		}

		//menuBarSelectedDelegate?.menuBarTapped(index: indexPath, indexToScrollTo: indexPathToScrollTo)
	}

	func findNextMonthImage(month: Month) -> UIImage {
		let month = month
		if let monthImage = UIImage(named: month.calendarImageName) {
			return monthImage.withRenderingMode(.alwaysTemplate)
		}
		return UIImage()
	}

    // MARK: Animations

    private func animateCalendarIconCell(month: Month, cell: _MenuBarCell, slideTo: CGFloat, jumpTo: CGFloat) {
        let rect = cell.imageView.frame
        let originX = rect.origin.x

        // slide icon
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
            cell.imageView.frame = CGRect(x: slideTo, y:  cell.imageView.frame.origin.y , width:  cell.imageView.frame.width, height:  cell.imageView.frame.height)
        }, completion: { _ in
            // jump across
            cell.imageView.frame = CGRect(x: jumpTo, y:  cell.imageView.frame.origin.y , width:  cell.imageView.frame.width, height:  cell.imageView.frame.height)
            cell.imageView.image = self.findNextMonthImage(month: month)
            // slide in
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
                cell.imageView.frame = CGRect(x: originX, y: cell.imageView.frame.origin.y , width: cell.imageView.frame.width, height:  cell.imageView.frame.height)
            })
        })
    }

	// MARK: Scrolling Month Animation
	// Only for MonthViewVC
	func determineCoordinatesForAnimations(monthToScrollTo: Month, previousMonth: Month) {
		let indexPath = IndexPath(item: currentMonth?.rawValue ?? 0, section: 0)

		if let cell = self.cellForItem(at: indexPath) as? _MenuBarCell {
			if cell.isSelected == true {

				// slide coordinates for moving icon
				var slideTo = cell.imageView.frame.origin.x - UIScreen.main.bounds.width / 5
				// jump icon back to the opposite side before sliding back into the cell.
				var jumpTo = cell.imageView.frame.origin.x + UIScreen.main.bounds.width / 5 * 2

				// need 4 options - I honestly can't figure out why, maths hurts.

				if previousMonth.rawValue ==  Month.december.rawValue && monthToScrollTo.rawValue == Month.january.rawValue {
					jumpTo = cell.imageView.frame.origin.x + UIScreen.main.bounds.width / 5 * 2
					slideTo = cell.imageView.frame.origin.x - UIScreen.main.bounds.width / 5
				} else if previousMonth.rawValue == Month.january.rawValue && monthToScrollTo.rawValue == Month.december.rawValue{
					slideTo = cell.imageView.frame.origin.x + UIScreen.main.bounds.width / 5
					jumpTo = cell.imageView.frame.origin.x - UIScreen.main.bounds.width / 5 * 2
					// if page slide to left
				} else if previousMonth.rawValue > monthToScrollTo.rawValue  {
					slideTo = cell.imageView.frame.origin.x + UIScreen.main.bounds.width / 5
					jumpTo = cell.imageView.frame.origin.x - UIScreen.main.bounds.width / 5 * 2
					// else page slide to right
				} else if previousMonth.rawValue < monthToScrollTo.rawValue {
					slideTo = cell.imageView.frame.origin.x - UIScreen.main.bounds.width / 5
					jumpTo = cell.imageView.frame.origin.x + UIScreen.main.bounds.width / 5 * 2

				}
				animateCalendarIconCell(month: monthToScrollTo, cell: cell, slideTo: slideTo, jumpTo: jumpTo)
			}
		}
	}
}

// MARK: CollectionView

extension MenuBar: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = 100
        return CGSize(width: collectionView.bounds.size.width, height: CGFloat(height))
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuBarViewModel.menuBarCells.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.layoutIfNeeded()

        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? _MenuBarCell {

            cell.updateViews(imageName: menuBarViewModel.menuBarCells[indexPath.row].imageName,
                             constraints: menuBarViewModel.menuBarCells[indexPath.row].constraints,
                             selected: menuBarViewModel.menuBarCells[indexPath.row].isSelected)

            if cell.isSelected {

                cell.isUserInteractionEnabled = false
            } else {
                cell.isUserInteractionEnabled = true
            }
            return cell
        }
        return _MenuBarCell()
    }
}

extension MenuBar: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateMenuBarDelegate(indexPath: indexPath.row)
        self.reloadData()
    }
}

extension MenuBar: UICollectionViewDelegateFlowLayout {

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        menuBarSelectedDelegate?.menuBarScrollFinished()
    }
}


