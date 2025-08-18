	//
	//  PeriodType.swift
	//  Seasonal
	//
	//  Created by Clint Thomas on 18/8/2025.
	//  Copyright © 2025 Clint Thomas. All rights reserved.
	//

import SwiftUI

protocol PeriodType: CaseIterable, Equatable, Hashable where AllCases: RandomAccessCollection {
	var name: String { get }
	var index: Int { get }
	var image: Image { get }
}

extension PeriodType {

	var name: String {
		String(describing: self).capitalized
	}

	var index: Int {
		Array(Self.allCases).firstIndex(of: self) ?? 0
	}
}
