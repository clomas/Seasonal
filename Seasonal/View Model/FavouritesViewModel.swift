//
//  _FavouritesViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 21/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//
//
//import Foundation
//
//final class _FavouritesViewModel {
//
//	var viewModel = [_ProduceModel]()
//
//	init(viewModel: [_ProduceModel]) {
//		self.viewModel = viewModel
//	}
//}
//
//extension _FavouritesViewModel {
//	func filterFavourites(searchString: String, filter: ViewDisplayed.ProduceFilter) -> [_ProduceModel] {
//		switch filter {
//		case .cancelled, .all:
//			if searchString == "" {
//				return self.viewModel.filter{$0.liked == true}
//			} else {
//				return self.viewModel.filter({ $0.produceName?.lowercased().contains(searchString.lowercased()) ?? false})
//			}
//		case .fruit, .vegetables, .herbs:
//			if searchString == "" {
//				return self.viewModel.filter({ $0.category == filter })
//			} else {
//				return self.viewModel.filter({ $0.category == filter &&
//												$0.produceName?.lowercased().contains(searchString.lowercased()) ?? false})
//			}
//		}
//	}
//}
