//
//  SwipeOnboardingTip.swift
//  Seasonal
//
//  Created by Clint Thomas on 27/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import TipKit

struct SwipeOnboardingTip: Tip {

	let context: String

	var id = "scroll-guide"

	var title: Text {
		Text(Strings.Onboarding.swipeTitle)
	}

	var message: Text? {
		Text(Strings.Onboarding.swipeMessage(context: context))
	}
}
