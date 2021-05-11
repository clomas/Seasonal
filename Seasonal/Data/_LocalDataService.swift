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
			do {
				try coreDataManager.save()
			} catch {
				print(error.localizedDescription)
				// TODO: Logging in all catches here
			}
		case .remove(let favouriteToRemove):
			favourites = favouriteToRemove
		}
	}

	func delete(id: Int) throws {
		do {
			try coreDataManager.delete(id: id)
		} catch {
			print(error.localizedDescription)
		}
	}

	func getFavourites() -> [Favourites] {
		do {
			return try coreDataManager.getEntityValues()
		} catch {
			print(error.localizedDescription)
			return [Favourites]()
		}
	}
}

