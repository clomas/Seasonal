//
//  LocalFavouritesTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 4/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Foundation
import Testing
@testable import Seasonal

struct LocalFavouritesTests {

    private let directory: URL
    private let favourites: LocalFavourites

    init() throws {
        directory = URL.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        favourites = LocalFavourites(directory: directory)
    }

    @Test func savesAndDeletesFavourites() {
        favourites.save(1)
        favourites.save(2)
        favourites.delete(1)

        #expect(favourites.ids == [2])
    }

    @Test func replacesAllFavourites() {
        favourites.save(1)
        favourites.save(2)
        favourites.replace(with: [2, 3])

        #expect(favourites.ids == [2, 3])
    }

    @Test func readsTheLegacyFileFormat() throws {
        try Data(#"{"id":42}"#.utf8).write(to: directory.appending(path: "42"))

        #expect(favourites.ids == [42])
    }

    @Test func ignoresFilesThatAreNotFavourites() throws {
        try Data("not json".utf8).write(to: directory.appending(path: "notes.txt"))
        favourites.save(3)

        #expect(favourites.ids == [3])
    }

    @Test func deletingAMissingFavouriteDoesNothing() {
        favourites.delete(99)

        #expect(favourites.ids.isEmpty)
    }
}
