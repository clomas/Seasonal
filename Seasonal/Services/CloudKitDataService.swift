//
//  CloudKitDataService.swift
//  Seasonal
//
//  Created by Clint Thomas on 1/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import CloudKit

actor CloudKitDataService {

    enum DatabaseType {
        case `private`
        case `public`
    }

    private let container = CKContainer.default()

    private var hasUbiquityIdentityToken: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    func fetchItems(_ databaseType: DatabaseType, recordType: String, queryKey: String) async throws -> [CKRecord] {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: queryKey, ascending: true)]

        let (matchResults, _) = try await database(databaseType).records(matching: query)
        return try matchResults.map { try $0.1.get() }
    }

    @discardableResult
    func saveItem(_ record: CKRecord, in databaseType: DatabaseType) async -> CKRecord? {
        guard hasUbiquityIdentityToken else { return nil }
        return try? await database(databaseType).save(record)
    }

    @discardableResult
    func deleteItem(_ record: CKRecord, in databaseType: DatabaseType) async -> CKRecord.ID? {
        guard hasUbiquityIdentityToken else { return nil }
        return try? await database(databaseType).deleteRecord(withID: record.recordID)
    }

    private func database(_ type: DatabaseType) -> CKDatabase {
        type == .private ? container.privateCloudDatabase : container.publicCloudDatabase
    }
}
