//
//  ProduceCell.swift
//  Seasonal
//
//  Created by Clint Thomas on 6/7/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

import SwiftUI

struct ProduceCell: View {

	private let dateHandler: DateHandler = DateHandler()

	var produce: ProduceModel = .init(id: 1, name: "Apples Apples Apples Apples Apples", category: .fruit, imageName: "Apples", description: "", months: [], seasons: [], liked: false)

	var body: some View {
		GeometryReader { geometry in
			if #available(iOS 26.0, *) {
				VStack(spacing: 0) {
					HStack {
						Image(produce.imageName)
						Spacer()
						Button(action: {
								//							produce.liked = !produce.liked
						}) {
							if produce.liked {
								GradientHeartView()
							} else {
								EmptyHeartView()
							}
						}
						.padding(.trailing, 10)
					}
					.overlay(
						Text("Apples")
							.font(.headline)
							.frame(width: geometry.size.width)
							.multilineTextAlignment(.center)
					)
					MonthsInSeasonCapsuleView()
				}
				.listRowSeparator(.hidden)
//				.frame(height: 60)
			}
		}
	}
}

#Preview {
	ProduceCell()
}
