//
//  MonthsCollectionView.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/3/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import UIKit

class MonthsCollectionView: UICollectionView {

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    func setupView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 2, height: self.frame.height / 5)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.collectionViewLayout = layout;
        self.allowsMultipleSelection = false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
    }
}
