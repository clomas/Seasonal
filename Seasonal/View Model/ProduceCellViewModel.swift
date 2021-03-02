//
//  ProduceCellViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/11/20.
//  Copyright © 2020 Clint Thomas. All rights reserved.
//

import Foundation


//https://softwareengineering.stackexchange.com/questions/213040/when-using-mvvm-should-you-create-new-viewmodels-or-swap-out-the-models


final class ProduceCellViewModel {

    var monthCellViewModel = [[ProduceModel]]()
    var produceCellVMs = [ProduceModel]()
    var seasonsCellVMs = [Season:[ProduceModel]]()

    var reloadTableViewClosure: (()->())?

    var numberOfProduceCellVMs: Int {
        return self.monthCellViewModel.count
    }

	init(produceData: [Produce]) {
        self.monthCellViewModel = self.sortIntoMonthArrays(produce: produceData)
        self.produceCellVMs = produceData.map{ProduceModel.init(produce: $0)}
        self.seasonsCellVMs = self.sortIntoSeasonArrays(produce: produceData)
        //self._monthCellVMs = self._sortIntoMonthArrays(produce: produceData)
    }

    func sortIntoMonthArrays(produce: [Produce]) -> [[ProduceModel]] {
        var monthProduceArr: [[ProduceModel]] = .init(repeating: [], count: 12)

        for monthIndex in 0...11 {
            var monthArray = [ProduceModel]()
            produce.forEach({ item in
                if item.months.contains(Month.init(rawValue: monthIndex)!) {
                    monthArray.append(ProduceModel.init(produce: item))
                }
            })
            monthProduceArr[monthIndex] = monthArray
        }

        return monthProduceArr
    }

    func sortIntoSeasonArrays(produce: [Produce]) -> [Season:[ProduceModel]] {
        var seasonsArray = [Season: [ProduceModel]]()

        Season.asArray.forEach { season in
            var seasonsProduce = [ProduceModel]()
            if season != Season.cancelled {
                produce.forEach({ item in
                    if item.seasons.contains(season) {
                        seasonsProduce.append(ProduceModel.init(produce: item))
                    }
                })
                seasonsArray[season] = seasonsProduce
            }
        }
        return seasonsArray
    }
}

extension ProduceCellViewModel {

    func filterMonthCellByCategory(searchString: String, filter: ViewDisplayed.ProduceFilter) -> [[ProduceModel]] {
        switch filter {
        case .cancelled, .all:
            if searchString == "" {
                return self.monthCellViewModel
            } else {
                return self.monthCellViewModel.map ({
                                                        return $0.filter({ $0.produceName?.lowercased().contains(searchString.lowercased()) ?? false})})
            }
        case .fruit, .vegetables, .herbs:
            if searchString == "" {
                return self.monthCellViewModel.map ({
                                                        return $0.filter({ $0.category == filter })})
            } else {
                return self.monthCellViewModel.map ({
                                                        return $0.filter({ $0.category == filter &&
                                                                            $0.produceName?.lowercased().contains(searchString.lowercased()) ?? false})})
            }
        }
    }

    func filterBySelectedCategories(season: Season, searchString: String, filter: ViewDisplayed.ProduceFilter) -> [ProduceModel] {
        switch filter {
        case .cancelled, .all:
            if searchString == "" {
                return self.seasonsCellVMs[season]!
            } else {
                return self.seasonsCellVMs[season]!.filter({ $0.produceName?.lowercased().contains(searchString.lowercased()) ?? false})
            }
        case .fruit, .vegetables, .herbs:
            if searchString == "" {
                return self.seasonsCellVMs[season]!.filter({ $0.category == filter })
            } else {
                return self.seasonsCellVMs[season]!.filter({ $0.category == filter &&
                                                             $0.produceName?.lowercased().contains(searchString.lowercased()) ?? false})
            }
        }
    }


    func likedDatabaseHandler(id: Int, liked: Bool) {
        for (monthIndex, month) in self.monthCellViewModel.enumerated() {

            if let likedProduceIndex = month.firstIndex(where: { $0.id == id }) {
                self.monthCellViewModel[monthIndex][likedProduceIndex].liked = liked
            } else {
                print("like index not found")
            }
        }

        let likedProduceIndex = self.produceCellVMs.firstIndex(where: { $0.id == id })!

        self.produceCellVMs[likedProduceIndex].liked = liked

        CloudKitDataHandler.instance.saveLikeToPrivateDatabaseInCloudKit(id: id)

        // Update in local database
        let likedProduce = LikedProduce(id: id)

        if liked == true {
            likedProduce.saveItem()
        } else {
            likedProduce.deleteItem()
        }
    }

    func findFavourites(searchString: String, filter: ViewDisplayed.ProduceFilter) -> [ProduceModel] {
        switch filter {
        case .cancelled, .all:

            if searchString == "" {
                return self.produceCellVMs.filter{$0.liked == true}
            } else {
                return self.produceCellVMs.filter({ $0.produceName?.lowercased().contains(searchString.lowercased()) ?? false})
            }
        case .fruit, .vegetables, .herbs:
            if searchString == "" {
                return self.produceCellVMs.filter({ $0.category == filter })
            } else {
                return self.produceCellVMs.filter({ $0.category == filter &&
                                                    $0.produceName?.lowercased().contains(searchString.lowercased()) ?? false})
            }
        }
    }

    func filterFavouritesBySearch(searchString: String) -> [ProduceModel] {
        return self.produceCellVMs.filter{($0.produceName!.contains(searchString))}
    }
}



struct ProduceModel {

    var produce: Produce!

    init(produce: Produce) {
        self.produce = produce
    }
    var id: Int {
        return self.produce.id
    }
    var produceName: String? {
        return self.produce.name
    }
    var imageName: String {
        return self.produce.imageName
    }
    var category: ViewDisplayed.ProduceFilter? {
        return self.produce.category
    }
    var months: [Month] {
        return self.produce.months
    }
    var seasons: [Season] {
        return self.produce.seasons
    }
    var liked: Bool {
        get {
            return self.produce.liked
        } set(liked) {
            self.produce.liked = liked
        }
    }
}

