//
//  LocalLikesTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 4/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Foundation
import Testing
@testable import Seasonal

struct LocalLikesTests {

    private let directory: URL
    private let likes: LocalLikes

    init() throws {
        directory = URL.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        likes = LocalLikes(directory: directory)
    }

    @Test func savesAndDeletesLikes() {
        likes.save(1)
        likes.save(2)
        likes.delete(1)

        #expect(likes.ids == [2])
    }

    @Test func readsTheLegacyFileFormat() throws {
        try Data(#"{"id":42}"#.utf8).write(to: directory.appending(path: "42"))

        #expect(likes.ids == [42])
    }

    @Test func ignoresFilesThatAreNotLikes() throws {
        try Data("not json".utf8).write(to: directory.appending(path: "notes.txt"))
        likes.save(3)

        #expect(likes.ids == [3])
    }

    @Test func deletingAMissingLikeDoesNothing() {
        likes.delete(99)

        #expect(likes.ids.isEmpty)
    }
}
