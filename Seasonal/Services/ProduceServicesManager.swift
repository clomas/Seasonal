//
//  ProduceServicesManager.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import CloudKit

@available(iOS 26, *)
struct ProduceServicesManager: ProduceProviding {

	private let localFavourites = LocalFavourites()
	private let pendingChanges = PendingFavouriteChanges()

	func produce(for location: StateLocation) async -> Result<[Produce], CKError> {
		await service(for: location).getData()
	}

	func favourites(for location: StateLocation, basedOn baseProduce: [Produce]) async -> [Produce] {
		await service(for: location).getFavourites(basedOn: baseProduce)
	}

	func updateFavourite(id: Int, isFavourite: Bool) async {
		if isFavourite {
			localFavourites.save(id)
		} else {
			localFavourites.delete(id)
		}

		let location = StateLocation(rawValue: GlobalSettings.location.state) ?? .noState
		await service(for: location).updateFavourite(id: id, isFavourite: isFavourite)
	}

	private func service(for location: StateLocation) -> ProduceCloudDataService {
		ProduceCloudDataService(location: location, localFavourites: localFavourites, pendingChanges: pendingChanges)
	}
}
