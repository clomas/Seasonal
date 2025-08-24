	//
	//  PeriodType.swift
	//  Seasonal
	//
	//  Created by Clint Thomas on 18/8/2025.
	//  Copyright © 2025 Clint Thomas. All rights reserved.
	//

import SwiftUI

enum NoPeriod: PeriodType {
	case `none`

	static let currentPeriod: NoPeriod = `none`

	var image: Image {
		Image(systemName: "")
	}
}

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

struct AnyPeriod: Hashable, Equatable {
	private let _equals: (AnyPeriod) -> Bool
	private let _hash: (inout Hasher) -> Void
	private let _name: () -> String
	private let _image: () -> Image
	private let _base: Any

	var name: String { _name() }
	var image: Image { _image() }

	init<T: PeriodType>(_ base: T) {
		_base = base
		_equals = { ($0._base as? T) == base }
		_hash = { $0.combine(base) }
		_name = { base.name }
		_image = { base.image }
	}

	static func == (lhs: AnyPeriod, rhs: AnyPeriod) -> Bool {
		lhs._equals(rhs)
	}

	func `is`<T: PeriodType>(_ type: T.Type) -> Bool { _base is T }

	func cast<T: PeriodType>(_ type: T.Type) -> T? { _base as? T }

	func hash(into hasher: inout Hasher) { _hash(&hasher) }
}

extension Collection where Element: PeriodType {
	// TODO: Rename and remove fatal error? optional?
	func element(atCyclicIndex index: Int) -> Element {
		let count = self.count
		guard count > 0 else {
			fatalError("Cannot access elements of empty collection")
		}
		var adjustedIndex = index % count
		if adjustedIndex < 0 {
			adjustedIndex += count
		}
		return self[self.index(self.startIndex, offsetBy: adjustedIndex)]
	}
}
