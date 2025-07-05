//
//  InfoViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/4/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

final class InfoViewModel {

	var location: StateLocation

	weak var coordinator: MainViewCoordinator?

	init(location: StateLocation) {
		self.location = location
	}
}
