//
//  _InfoViewModel.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/4/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//

import Foundation

final class _InfoViewModel {

	weak var coordinator: _MainViewCoordinator?
	var location: StateLocation
	
	init(location: StateLocation) {
		self.location = location
	}
}

