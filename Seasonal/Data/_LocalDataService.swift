//
//  _LocalDataService.swift
//  Seasonal
//
//  Created by Clint Thomas on 1/3/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation
import CoreData

protocol LocalFavouritesProtocol {
	func update(_ action: _LocalDataService.FavouriteAction, data: _LocalDataService.FavouritesData)
}

final class _LocalDataService: LocalFavouritesProtocol {

	struct FavouritesData {
		let id: Int16
	}

	enum FavouriteAction {
		case add
		case remove(Favourites)
	}

	private let coreDataManager: CoreDataManager

	init(coreDataManager: CoreDataManager = .shared) {
		self.coreDataManager = coreDataManager
	}

	func update(_ action: _LocalDataService.FavouriteAction, data: FavouritesData) {

		var favourites: Favourites

		switch action {
		case .add:
			favourites = Favourites(context: coreDataManager.managedObjectContext)
			favourites.setValue(data.id, forKey: "id")
			coreDataManager.save()
		case .remove(let favouriteToRemove):
			favourites = favouriteToRemove
		}
	}

	func delete(id: Int) {
		coreDataManager.delete(id: id)
	}

	func getFavourites() -> [Favourites] {
		coreDataManager.getEntityValues()
	}
}

