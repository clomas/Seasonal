//
//  CloudKitDataService.swift
//  Seasonal
//
//  Created by Clint Thomas on 1/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import CloudKit

struct CloudKitDataService: Sendable {

    enum DatabaseType {
        case `private`
        case `public`
    }

    private let container = CKContainer.default()

    var hasUbiquityIdentityToken: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    func fetchItems(_ databaseType: DatabaseType, recordType: String, queryKey: String) async throws -> [CKRecord] {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: queryKey, ascending: true)]

        let database = database(databaseType)
        var (matchResults, cursor) = try await database.records(matching: query)
        while let nextCursor = cursor {
            let page = try await database.records(continuingMatchFrom: nextCursor)
            matchResults += page.matchResults
            cursor = page.queryCursor
        }
        return try matchResults.map { try $0.1.get() }
    }

    func saveItem(_ record: CKRecord, in databaseType: DatabaseType) async throws {
        guard hasUbiquityIdentityToken else { return }
        _ = try await database(databaseType).save(record)
    }

    func deleteItem(_ record: CKRecord, in databaseType: DatabaseType) async throws {
        guard hasUbiquityIdentityToken else { return }
        do {
            try await database(databaseType).deleteRecord(withID: record.recordID)
        } catch let error as CKError where error.code == .unknownItem {
            return
        }
    }

    private func database(_ type: DatabaseType) -> CKDatabase {
        type == .private ? container.privateCloudDatabase : container.publicCloudDatabase
    }
}
