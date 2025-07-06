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

	let produce: Produce = .init(produce: .init(id: 1, name: "apple", category: .fruit, imageName: "apple", description: "", months: [], seasons: [], liked: true))

    var body: some View {
		HStack {
			Image(systemName: produce.imageName)

			VStack(alignment: .leading) {
				Text("Apples")
				HStack {
					ForEach(Month.allCases, id: \.self) { month in
						ZStack {
							if month == dateHandler.findMonthAndSeason().month {
								Circle()
									.fill(Colour.inSeason)
									.frame(width: 30, height: 30)

								Text(month.firstLetter)
									.foregroundStyle(.white)
									.padding(4)
							} else {
								Text(month.firstLetter)
									.padding(4)
							}
						}
					}
				}
			}
			Button() {

			}
		}
    }
}

#Preview {
    ProduceCell()
}
