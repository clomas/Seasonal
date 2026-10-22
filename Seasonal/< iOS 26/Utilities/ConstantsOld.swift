//
//  ConstantsOld.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/2/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import Foundation

struct ConstantsOld {

	static let seasonal: String = "Seasonal"

	// MARK: - Locations
    
	static let straya: String = "Australia"

	// MARK: - CloudKit
    
	static let australianProduce: String = ProduceRecordKey.australianProduce
	static let australianProduceLikes: String = ProduceRecordKey.australianProduceFavourites

	// MARK: - Record fields
    
	static let id: String = ProduceRecordKey.id
	static let name: String = ProduceRecordKey.name
	static let category: String = ProduceRecordKey.category
	static let cancelled: String = "cancelled"

	// MARK: - Icons & labels
    
	static let allCategories: String = "allCategories"
	static let favourites: String = "favourites"
	static let seasons: String = "seasons"
	static let categories: String = "categories"
	static let months: String = "months"
	static let all: String = "all"
	static let fruit: String = "fruit"
	static let vegetables: String = "vegetables"
	static let herbs: String = "herbs"
	static let cancel: String = "cancel"

	// MARK: - Titles
    
	static let selectAMonth: String = "Select a Month"

	// MARK: - Cell identifiers
    
	static let SeasonsTableViewCell: String = "SeasonsTableViewCell"
	static let ProduceMonthInfoViewCell: String = "ProduceMonthInfoViewCell"
	static let MenuBarCell: String = "MenuBarCell"
	static let SelectMonthCell: String = "SelectMonthCollectionViewCell"
	static let MonthTableCell: String = "MonthTableCollectionViewCell"

	// MARK: - Colours
    
	static let tableViewCellColor: String = "cellColor"
	static let searchBarColor: String = "searchBar"
	static let likeButtonColor: String = "likeButton"
	static let inSeasonColor: String = "inSeason"
	static let nonSeasonColor: String = "nonSeason"
	static let menuBarColor: String = "menuBar"
	static let menuBarSelectedColor: String = "menuBarSelected"
	static let navigationBarColor: String = "navigationBar"

	// MARK: - Videos
    
	static let lightWelcomeVideo: String = "lightwelcomevideo"
	static let darkWelcomeVideo: String = "darkwelcomevideo"

	// MARK: - Likes
    
	static let liked: String = "liked"
	static let unliked: String = "unliked"

	// MARK: - Welcome
    
	static let welcomeToSeasonal: String = "Welcome to Seasonal"

	// MARK: - Info
	// swiftlint:disable:next line_length
    
	static let infoPageSpiel: String = "Location of Produce Displayed: Australia.\n\n\n It's never been more important to eat local and in season, mass scale farming and mono cropping is depleting nutrients in the soil and intern our food suffers. Frozen and imported produce is sold year round, causing further depletion of nutrients in our food. I hope this app can help users make a more informed decisions about their produce.\n \n I’m always looking to improve the accuracy of the application, so get in contact if you have any suggestions, corrections or additional information you would like to see in this app. Thanks for downloading!"

	static let apple: String = "apple"

	static let allLocations: [String] = [
		StateLocation.westernAustralia.fullName.capitalized,
		StateLocation.southAustralia.fullName.capitalized,
		StateLocation.northernTerritory.fullName.capitalized,
		StateLocation.queensland.fullName.capitalized,
		StateLocation.newSouthWales.fullName.capitalized,
		StateLocation.victoria.fullName.capitalized,
		StateLocation.tasmania.fullName.capitalized
	]

}
