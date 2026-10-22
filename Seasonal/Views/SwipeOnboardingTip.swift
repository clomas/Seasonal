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

	/// Versioned because TipKit remembers a closed tip forever, and this one should return after an update.
	var id: String {
		"scroll-guide-\(Bundle.main.shortVersion ?? "")"
	}

	var title: Text {
		Text(Strings.Onboarding.swipeTitle)
	}

	var message: Text? {
		Text(Strings.Onboarding.swipeMessage(context: context))
	}
}
