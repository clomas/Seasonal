//
//  FoodOrMonth.swift
//  Seasonsal
//
//  Created by Clint Thomas on 12/10/18.
//  Copyright © 2018 Clint Thomas. All rights reserved.
//

import Foundation

struct CSVProduceCellModel {

    public var id: Int
    private(set) public var category: String
    private(set) public var name: String
    private(set) public var imageName: String
    private(set) public var description: String
    private(set) public var months_aus: String
    private(set) public var season_aus: String
    private(set) public var months_wa: String
    private(set) public var season_wa: String
    private(set) public var months_sa: String
    private(set) public var season_sa: String
    private(set) public var months_nt: String
    private(set) public var season_nt: String
    private(set) public var months_tas: String
    private(set) public var season_tas: String
    private(set) public var months_vic: String
    private(set) public var season_vic: String
    private(set) public var months_nsw: String
    private(set) public var season_nsw: String
    private(set) public var months_qld: String
    private(set) public var season_qld: String
    public var liked: Int

    init (id: Int, category: String, name: String, imageName: String, description: String, months_aus: String, season_aus: String, months_wa: String, season_wa: String, months_sa: String, season_sa: String, months_nt: String, season_nt: String, months_tas: String, season_tas: String, months_vic: String, season_vic: String, months_nsw: String, season_nsw: String, months_qld: String, season_qld: String, liked: Int ) {

        self.id = id
        self.category = category
        self.name = name
        self.imageName = imageName
        self.description = description
        self.months_aus = months_aus
        self.season_aus = season_aus
        self.months_wa = months_wa
        self.season_wa = season_wa
        self.months_sa = months_sa
        self.season_sa = season_sa
        self.months_nt = months_nt
        self.season_nt = season_nt
        self.months_tas = months_tas
        self.season_tas = season_tas
        self.months_vic = months_vic
        self.season_vic = season_vic
        self.months_nsw = months_nsw
        self.season_nsw = season_nsw
        self.months_qld = months_qld
        self.season_qld = season_qld
        self.liked = liked

    }
}

struct csvData {
    var id = Int()
    var name = String()
    var category = String()
    var description = String()
    var seasons_aus = String()
    var months_aus = String()
    var seasons_wa = String()
    var months_wa = String()
    var seasons_sa = String()
    var months_sa = String()
    var seasons_nt = String()
    var months_nt = String()
    var seasons_tas = String()
    var months_tas = String()
    var seasons_vic = String()
    var months_vic = String()
    var seasons_nsw = String()
    var months_nsw = String()
    var seasons_qld = String()
    var months_qld = String()
}

