//
//  Strings.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Foundation

enum Strings {

    enum Tab {
        static let favourites = String(localized: "Favourites")
        static let months = String(localized: "Months")
        static let seasons = String(localized: "Seasons")
        static let search = String(localized: "Search")
    }

    enum Month {
        static let january = String(localized: "January")
        static let february = String(localized: "February")
        static let march = String(localized: "March")
        static let april = String(localized: "April")
        static let may = String(localized: "May")
        static let june = String(localized: "June")
        static let july = String(localized: "July")
        static let august = String(localized: "August")
        static let september = String(localized: "September")
        static let october = String(localized: "October")
        static let november = String(localized: "November")
        static let december = String(localized: "December")
    }

    enum Season {
        static let summer = String(localized: "Summer")
        static let autumn = String(localized: "Autumn")
        static let winter = String(localized: "Winter")
        static let spring = String(localized: "Spring")
    }

    enum Produce {
        static let inSeason = String(localized: "In season")
        static let allYear = String(localized: "All year")

        static func monthRange(from start: String, to end: String) -> String {
            String(localized: "\(start) to \(end)")
        }
    }

    enum State {
        static let australia = String(localized: "Australia")
        static let australianCapitalTerritory = String(localized: "Australian Capital Territory")
        static let newSouthWales = String(localized: "New South Wales")
        static let northernTerritory = String(localized: "Northern Territory")
        static let queensland = String(localized: "Queensland")
        static let southAustralia = String(localized: "South Australia")
        static let tasmania = String(localized: "Tasmania")
        static let victoria = String(localized: "Victoria")
        static let westernAustralia = String(localized: "Western Australia")
    }

    enum Favourite {
        static let label = String(localized: "Favourite")
    }

    enum Search {
        static let prompt = String(localized: "Search produce")
    }

    enum Category {
        static let fruit = String(localized: "Fruit")
        static let vegetables = String(localized: "Vegetables")
        static let herbs = String(localized: "Herbs")
        static let all = String(localized: "All")
    }

    enum Filter {
        static let label = String(localized: "Filter by category")
        static let hint = String(localized: "Filters the produce list by category")
        static let allCategories = String(localized: "All categories")
    }

    enum Jump {
        static let toMonth = String(localized: "Jump to a month")
        static let toSeason = String(localized: "Jump to a season")
    }

    enum EmptyState {
        static let favourites = String(localized: "No favourites selected")
        static let period = String(localized: "Nothing to display, try something else")
    }

    enum Launch {
        static let networkErrorTitle = String(localized: "Network Error")
        static let networkErrorMessage = String(localized: "Unable to connect to the internet")
        static let chooseLocation = String(localized: "Choose your location")
        static let findLocationAgain = String(localized: "Try find location again")
        static let tryAgain = String(localized: "Try again")
        static let loading = String(localized: "Loading produce")
    }

    enum CloudError {
        static let title = String(localized: "iCloud Error")
        static let notSignedIn = String(localized: "Your data is stored privately in your own iCloud. Open Settings to sign in.")
        static let network = String(localized: "Check your network and try again.")
        static let storageFull = String(localized: "Free up iCloud storage to continue.")
        static let unavailable = String(localized: "iCloud is temporarily unavailable. Try again later.")
    }

    enum Settings {
        static let button = String(localized: "Settings")
        static let title = String(localized: "Seasonal")
        static let locationSection = String(localized: "Location")
        static let produceLocation = String(localized: "Produce location")
        static let aboutSection = String(localized: "About")
        static let viewSource = String(localized: "View source on GitHub")
        static let privacyPolicy = String(localized: "Privacy policy")
        static let getInTouch = String(localized: "Get in touch")
        static let appearanceSection = String(localized: "Appearance")
        static let themePicker = String(localized: "Colour")
        static let appearancePicker = String(localized: "Light/Dark Mode")
        static let themeFooter = String(localized: "Match current season changes the accent colour through the year.")
        // swiftlint:disable:next line_length
        static let intro: String = String(localized: "It's never been more important to eat local and in season, mass scale farming and mono cropping is depleting nutrients in the soil and intern our food suffers. Frozen and imported produce is sold year round, causing further depletion of nutrients in our food. I hope this app can help users make a more informed decisions about their produce.\n\nI’m always looking to improve the accuracy of the application, so get in contact if you have any suggestions, corrections or additional information you would like to see in this app. Thanks for downloading!")

        static func version(_ version: String) -> String {
            String(localized: "Seasonal \(version)")
        }
    }

    enum Theme {
        static let automatic = String(localized: "Match current season")
        static let fresh = String(localized: "Fresh")
        static let citrus = String(localized: "Citrus")
        static let berry = String(localized: "Berry")
        static let ocean = String(localized: "Ocean")
    }

    enum Appearance {
        static let automatic = String(localized: "Automatic")
        static let light = String(localized: "Light")
        static let dark = String(localized: "Dark")
    }

    enum Onboarding {
        static let swipeTitle = String(localized: "Swipe to explore")
        static let monthsContext = String(localized: "months")
        static let seasonsContext = String(localized: "seasons")

        static func swipeMessage(context: String) -> String {
            String(localized: "You can scroll left and right to see other \(context).")
        }
    }
}
