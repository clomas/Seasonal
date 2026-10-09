//
//  LocalLikes.swift
//  Seasonal
//
//  Created by Clint Thomas on 4/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Foundation

/// The likes saved on this device: one file per produce ID, named after the ID. The legacy app
/// reads and writes the same files, so likes carry over between the two.
struct LocalLikes: Sendable {

    private struct Record: Codable {
        let id: Int
    }

    private let directory: URL

    var ids: Set<Int> {
        let files = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        return Set(files.compactMap { url in
            guard let data = try? Data(contentsOf: url) else { return nil }
            return (try? JSONDecoder().decode(Record.self, from: data))?.id
        })
    }

    init(directory: URL = .documentsDirectory) {
        self.directory = directory
    }

    func save(_ id: Int) {
        guard let data = try? JSONEncoder().encode(Record(id: id)) else { return }
        try? data.write(to: fileURL(for: id), options: .atomic)
    }

    func delete(_ id: Int) {
        try? FileManager.default.removeItem(at: fileURL(for: id))
    }

    private func fileURL(for id: Int) -> URL {
        directory.appending(path: "\(id)", directoryHint: .notDirectory)
    }
}
