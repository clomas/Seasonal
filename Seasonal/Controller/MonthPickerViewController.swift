//
//  MonthSelectViewController.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/3/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit

class MonthPickerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate,  UICollectionViewDelegateFlowLayout, Storyboarded {

    weak var coordinator: MainCoordinator?
    var monthSelectViewTapped: ((_ indexSelected: Month) -> Void)?

    @IBOutlet weak var monthCollectionView: UICollectionView!

    var currentMonthSelected: Month?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        monthCollectionView.delegate = self
        monthCollectionView.dataSource = self
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Month.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SELECTMONTHCELL, for: indexPath) as? MonthPickerCell {

            cell.updateViews(month: Month.asArray[indexPath.row])
            
            return cell
        } else {
            return MonthPickerCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        monthSelectViewTapped?(Month.init(rawValue: indexPath.row)!)
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

    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

}
