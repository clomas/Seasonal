//
//  Feature.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

enum Feature: String, CaseIterable {
	case useSwiftUI

	var defaultValue: Bool {
		switch self {
		case .useSwiftUI:
			if #available(iOS 26, *) { true } else { false }
		}
	}
}
