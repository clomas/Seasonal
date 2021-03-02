//
//  _CoreDataManager.swift
//  Seasonal
//
//  Created by Clint Thomas on 1/3/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import CoreData

enum ManagedObjectError: String, Error {
	case invalidID = "id wasn't found"
	case response = "no response"
}

extension ManagedObjectError:LocalizedError {
	var errorDescription: String? { return NSLocalizedString(rawValue, comment: "")}
}

final class CoreDataManager {

	static let shared = CoreDataManager()

	lazy var persistentContainer: NSPersistentContainer = {
		let persistentContainer = NSPersistentContainer(name: "Seasonal")
		persistentContainer.loadPersistentStores { _, error in
			print(error?.localizedDescription ?? "")
		}
		return persistentContainer
	}()

	var managedObjectContext: NSManagedObjectContext {
		persistentContainer.viewContext // main context
	}

	// TODO: Error handling here
	func delete(id: Int) {

		do {
			let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favourites")
			fetchRequest.predicate = NSPredicate.init(format: "id =\(id)")

			if let result = try? managedObjectContext.fetch(fetchRequest) {
				for object in result {
					managedObjectContext.delete(object as! NSManagedObject)
				}
			}
			try managedObjectContext.save()
		} catch _ {
			// error handling
		}
	}

	func save() {
		do {
			try managedObjectContext.save()
		} catch {
			print(error)
		}
	}

	func getEntityValues<T: NSManagedObject>() -> [T] {
		do {
			let fetchRequest = NSFetchRequest<T>(entityName: "\(T.self)")
			return try managedObjectContext.fetch(fetchRequest)
		} catch {
			print(error)
			return []
		}
	}

}

