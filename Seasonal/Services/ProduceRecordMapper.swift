//
//  ProduceRecordMapper.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import CloudKit

/// Converts public-database records into `Produce` for one state. Months and seasons are stored
/// per state as strings, so parsing them relies on string matching.
struct ProduceRecordMapper {

    let location: StateLocation

    private let inSeasonFlag: Character = "1"

    func produce(from records: [CKRecord]) -> [Produce] {
        records.map(produce(from:))
    }

    private func produce(from record: CKRecord) -> Produce {
        guard let id = record.object(forKey: Constants.id) as? Int,
              let name = record.object(forKey: Constants.name) as? String,
              let category = record.object(forKey: Constants.category) as? String,
              let monthFlags = record.object(forKey: "months_\(location.rawValue)") as? String,
              let seasonCodes = record.object(forKey: "seasons_\(location.rawValue)") as? String
        else {
            return placeholder
        }

        return Produce(
            id: id,
            name: name,
            category: produceCategory(from: category),
            imageName: name,
            description: "",
            months: months(from: monthFlags),
            seasons: seasons(from: seasonCodes),
            liked: false
        )
    }

    private var placeholder: Produce {
        Produce(
            id: 0,
            name: Constants.apple,
            category: .fruit,
            imageName: Constants.apple,
            description: "",
            months: [],
            seasons: [],
            liked: false
        )
    }

    private func produceCategory(from value: String) -> ProduceCategory {
        switch value {
        case "vegetables": .vegetables
        case "herbs": .herbs
        default: .fruit
        }
    }

    /// One character per month, January first; `1` marks it as in season.
    private func months(from flags: String) -> [Months] {
        flags.enumerated().compactMap { offset, flag in
            flag == inSeasonFlag ? Months(rawValue: offset + 1) : nil
        }
    }

    private func seasons(from codes: String) -> [Seasons] {
        Seasons.allCases.filter { codes.contains($0.shortName) }
    }
}
