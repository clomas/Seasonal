//
//  Constants.swift
//  Seasonal
//
//  Created by Clint Thomas on 20/2/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import SwiftUI

struct Constants {

	// User defaults
	static let location: String = "Location"

	static let seasonal: String = "Seasonal"

	// Locations
	static let straya: String = "Australia"

	// CloudKit db
	static let australianProduce: String = "Australian_Produce"
	static let australianProduceLikes: String = "Australian_Produce_Likes"

	// General
	static let id: String = "id"
	static let season: String = "season"
	static let title: String = "title"
	static let description: String = "description"
	static let name: String = "name"
	static let cancelled: String = "cancelled"
	static let category: String = "category"

	// Icons Images & Labels
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

	// Titles
	static let Seasons: String = "Seasons"
	static let Months: String = "Months"
	static let selectAMonth: String = "Select a Month"

	// Cells
	static let SeasonsTableViewCell: String = "SeasonsTableViewCell"
	static let MenuBarCellSeason: String = "MenuBarCellSeason"
	static let ProduceMonthInfoViewCell: String = "ProduceMonthInfoViewCell"
	static let MenuBarCell: String = "MenuBarCell"
	static let SelectMonthCell: String = "SelectMonthCollectionViewCell"
	static let MonthTableCell: String = "MonthTableCollectionViewCell"

	// Colours / Tints
	static let tableViewCellColor: String = "cellColor"
	static let searchBarColor: String = "searchBar"
	static let likeButtonColor: String = "likeButton"
	static let inSeasonColor: String = "inSeason"
	static let nonSeasonColor: String = "nonSeason"
	static let menuBarColor: String = "menuBar"
	static let menuBarSelectedColor: String = "menuBarSelected"
	static let navigationBarColor: String = "navigationBar"

	// Videos
	static let lightWelcomeVideo: String = "lightwelcomevideo"
	static let darkWelcomeVideo: String = "darkwelcomevideo"

	// Likes
	static let liked: String = "liked"
	static let unliked: String = "unliked"

	// Welcome
	static let welcomeToSeasonal: String = "Welcome to Seasonal"

	// Info page spiel
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

	static let animationDuration: TimeInterval = 1.2
}

extension Image {
	static let arrowLeft: Image = .init(systemName: "arrow.left")
	static let arrowRight: Image = .init(systemName: "arrow.right")
	static let calendar: Image = .init(systemName: "calendar")
	static let seasons: Image = .init(systemName: .seasons)
	static let heart: Image = .init(systemName: "heart")
	static let heartFill: Image = .init(systemName: "heart.fill")
	static let magnifyingGlass: Image = .init(systemName: "magnifyingglass")
	static let settings: Image = .init(systemName: "slider.vertical.3")
}

// MARK: Image strings

extension String {
	static let calendarImage: String = "calendar"
	static let fruit: String = "apple.logo"
	static let herbs: String = "leaf.fill"
	static let settings: String = "slider.vertical.3"
	static let vegetables: String = "carrot.fill"
	static let seasons: String = "cloud.sun.fill"

	static func nothingToSeeHereMessage(tryAnother: String?) -> String {
		"Nothing to see ere, try another \(tryAnother ?? "")."
	}
}

// MARK: Time intervals

extension TimeInterval {
	static let lazyHStackScrollDuration: TimeInterval = 0.5
}

// MARK: Space

extension CGFloat {
	static let largePadding: CGFloat = 200
}
