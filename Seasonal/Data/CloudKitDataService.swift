//
//  Untitled.swift
//  Seasonal
//
//  Created by Clint Thomas on 1/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import Foundation
import CloudKit
import Combine

@MainActor
final class CloudKitDataService: ObservableObject {
	@Published var items: [CKRecord] = []
	@Published var isLoading = false
	@Published var errorMessage: String?

	private let container: CKContainer
	private let database: CKDatabase

	init(container: CKContainer = .default()) {
		self.container = container
		self.database = container.privateCloudDatabase
	}

	func fetchItems(recordType: String) async {
		let predicate = NSPredicate(value: true)
		let query = CKQuery(recordType: recordType, predicate: predicate)

		do {
			let (matchResults, _) = try await database.records(matching: query)

			let records = matchResults.compactMap { (_, result) in
				switch result {
				case .success(let record): return record
				case .failure: return nil
				}
			}

			await MainActor.run {
				self.items = records
			}

		} catch {
			await MainActor.run {
				self.errorMessage = error.localizedDescription
			}
		}
	}

	func saveItem(_ record: CKRecord, completion: ((Result<CKRecord, Error>) -> Void)? = nil) {
		database.save(record) { [weak self] savedRecord, error in
			DispatchQueue.main.async {
				if let error = error {
					self?.errorMessage = error.localizedDescription
					completion?(.failure(error))
				} else if let saved = savedRecord {
					self?.items.append(saved)
					completion?(.success(saved))
				}
			}
		}
	}

	func deleteItem(_ record: CKRecord) {
		database.delete(withRecordID: record.recordID) { [weak self] recordID, error in
			DispatchQueue.main.async {
				guard let self = self else { return }

				if let error = error {
					self.errorMessage = error.localizedDescription
				} else if let id = recordID {
					self.items.removeAll { $0.recordID == id }
				}
			}
		}
	}
}
