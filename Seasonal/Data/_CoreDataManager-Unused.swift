//
//  _CoreDataManager.swift
//  Seasonal
//
//  Created by Clint Thomas on 1/3/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//
// TODO: make sure this is doing something
import CoreData

enum ManagedObjectError: String, Error {
	case invalidID = "id wasn't found"
	case response = "no response"
	case saveFailed = "MOC save has failed"
	case deleteFailed = "MOC delete has failed"
	case getEntityFailed = "Unable to get entity values"
}

extension ManagedObjectError: LocalizedError {
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

	func delete(id: Int) throws {

		do {
			let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favourites")
			fetchRequest.predicate = NSPredicate.init(format: "id =\(id)")

			if let result = try? managedObjectContext.fetch(fetchRequest) {
				for object in result {
					managedObjectContext.delete(object as! NSManagedObject)
				}
			} else {
				throw ManagedObjectError.invalidID
			}
			try managedObjectContext.save()
		} catch _ {
			throw ManagedObjectError.deleteFailed
		}
	}

	func save() throws {
		do {
			try managedObjectContext.save()
		} catch {
			throw ManagedObjectError.saveFailed
		}
	}

	func getEntityValues<T: NSManagedObject>() throws -> [T] {
		do {
			let fetchRequest = NSFetchRequest<T>(entityName: "\(T.self)")
			return try managedObjectContext.fetch(fetchRequest)
		} catch {
			throw ManagedObjectError.getEntityFailed
		}
	}
}

