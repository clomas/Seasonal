//
//  EmptyHeartView.swift
//  Seasonal
//
//  Created by Clint Thomas on 12/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

struct EmptyHeartView: View {
	var body: some View {
		Image(systemName: "heart")
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: 40, height: 60)
			.foregroundColor(.black)
			//			.foregroundStyle(
			//				LinearGradient(
			//					colors: [Color.black, Color.red],
			//					startPoint: .bottomTrailing,
			//					endPoint: .topLeading
			//				)
			//			)
	}
}
