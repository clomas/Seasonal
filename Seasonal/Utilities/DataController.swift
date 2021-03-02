//
//  DataController.swift
//  Seasonal
//
//  Created by Clint Thomas on 19/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

// For storing temporary App State data in memory.

import Foundation
import CoreData

class DataController: ObservableObject {
	let container: NSPersistentCloudKitContainer

	init() {
		container = NSPersistentCloudKitContainer(name: "Main")
		container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
		container.loadPersistentStores { storeDescription, error in
			if let error = error {
				fatalError("Fatal error loading store: \(error.localizedDescription)")
			}
		}
	}

	func createSampleAppState() throws {
		let viewContext = container.viewContext

//		let appState = AppState(context: viewContext)
//		appState.onPage = 0
//		appState.month = 12
//		appState.season = 0
//		appState.filter = 5

		try viewContext.save()
	}

	func save() {
		if container.viewContext.hasChanges {
			try? container.viewContext.save()
		}
	}

	func delete(_ object: NSManagedObject) {
		container.viewContext.delete(object)
	}
}

