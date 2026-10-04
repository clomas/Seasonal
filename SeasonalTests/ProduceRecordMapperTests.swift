//
//  ProduceRecordMapperTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import CloudKit
import Testing
@testable import Seasonal

struct ProduceRecordMapperTests {

    private let mapper = ProduceRecordMapper(location: .victoria)

    @Test func mapsAllFieldsForTheLocation() throws {
        let record = makeRecord(id: 7, name: "Apples", category: "fruit", months: "110000000011", seasons: "sum,aut")

        let produce = try #require(mapper.produce(from: [record]).first)

        #expect(produce.id == 7)
        #expect(produce.name == "Apples")
        #expect(produce.imageName == "Apples")
        #expect(produce.category == .fruit)
        #expect(produce.months == [.january, .february, .november, .december])
        #expect(produce.seasons == [.summer, .autumn])
        #expect(produce.liked == false)
    }

    @Test(arguments: [
        ("vegetables", ProduceCategory.vegetables),
        ("herbs", .herbs),
        ("fruit", .fruit),
        ("anything-else", .fruit)
    ])
    func categoryMapping(_ category: String, expected: ProduceCategory) throws {
        let record = makeRecord(id: 1, name: "Item", category: category, months: "", seasons: "")

        let produce = try #require(mapper.produce(from: [record]).first)

        #expect(produce.category == expected)
    }

    @Test(arguments: Seasons.allCases)
    func seasonShortNameIsMapped(_ season: Seasons) throws {
        let record = makeRecord(id: 1, name: "Item", category: "fruit", months: "", seasons: season.shortName)

        let produce = try #require(mapper.produce(from: [record]).first)

        #expect(produce.seasons == [season])
    }

    @Test func seasonsFollowCanonicalOrder() throws {
        let record = makeRecord(id: 1, name: "Item", category: "fruit", months: "", seasons: "spr win")

        let produce = try #require(mapper.produce(from: [record]).first)

        #expect(produce.seasons == [.winter, .spring])
    }

    @Test func otherStatesFieldsAreIgnored() throws {
        let record = CKRecord(recordType: Constants.australianProduce)
        record.setValue(1, forKey: Constants.id)
        record.setValue("Item", forKey: Constants.name)
        record.setValue("fruit", forKey: Constants.category)
        record.setValue("111111111111", forKey: "months_nsw")
        record.setValue("sum", forKey: "seasons_nsw")

        let produce = try #require(mapper.produce(from: [record]).first)

        #expect(produce.id == 0, "A record missing this state's fields maps to the placeholder")
    }

    @Test func incompleteRecordMapsToPlaceholder() throws {
        let record = CKRecord(recordType: Constants.australianProduce)

        let produce = try #require(mapper.produce(from: [record]).first)

        #expect(produce.id == 0)
        #expect(produce.name == Constants.apple)
        #expect(produce.months == [])
    }

    private func makeRecord(id: Int, name: String, category: String, months: String, seasons: String) -> CKRecord {
        let record = CKRecord(recordType: Constants.australianProduce)
        record.setValue(id, forKey: Constants.id)
        record.setValue(name, forKey: Constants.name)
        record.setValue(category, forKey: Constants.category)
        record.setValue(months, forKey: "months_vic")
        record.setValue(seasons, forKey: "seasons_vic")
        return record
    }
}
