	//
	//  PeriodType.swift
	//  Seasonal
	//
	//  Created by Clint Thomas on 18/8/2025.
	//  Copyright © 2025 Clint Thomas. All rights reserved.
	//

import SwiftUI

protocol PeriodType: CaseIterable, Equatable, Hashable where AllCases: RandomAccessCollection {

	static var currentPeriod: Self { get }
	static var allCases: [Self] { get }

	var name: String { get }
	var nameLowercased: String { get }
	var index: Int { get }
	var image: Image { get }
}

extension PeriodType {

	var name: String {
		String(describing: self).capitalized
	}

	var nameLowercased: String {
		String(describing: self)
	}

	var index: Int {
		allCases.firstIndex(of: self) ?? 0
	}

	var allCases: [Self] {
		Array(Self.allCases)
	}
}
