//
//  SwipeOnboardingTip.swift
//  Seasonal
//
//  Created by Clint Thomas on 27/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import TipKit

struct SwipeOnboardingTip: Tip {

	var id: String = "scroll-guide"

	var title: Text {
		Text("Swipe to explore")
	}

	var context: String?

	var message: Text? {
		Text("You can scroll left and right to see other \(context).")
	}
}
