	//
	//  ProduceList.swift
	//  Seasonal
	//
	//  Created by Clint Thomas on 27/7/2025.
	//  Copyright © 2025 Clint Thomas. All rights reserved.
	//

import SwiftUI

struct ProduceList: View {
	let produce: [ProduceModel]
	
	var body: some View {
		ZStack {
			Colour.background.ignoresSafeArea()
			List(produce, id: \.id) { item in
				ProduceCell(produce: item)
					.listRowSeparator(.visible)
					.listRowInsets(.topListRowInset)
					.listRowBackground(Color.clear)
				
				
			}
			.listStyle(.plain)
			.scrollContentBackground(.hidden)
				//			.padding(.top, -8)
		}
	}
}
