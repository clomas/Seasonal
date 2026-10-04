//
//  PreviewConstants.swift
//  Seasonal
//
//  Created by Clint Thomas on 21/8/2025.
//  Copyright © 2025 Clint Thomas. All rights reserved.
//

#if DEBUG

@available(iOS 26, *)
@MainActor
let previewCoordinator: AppCoordinator = {
	let coord = AppCoordinator(window: .create())
    coord.state = .initial
	coord.produceStore.loadMockData(previewProduce)
	return coord
}()

/// Fixtures shared by the SwiftUI previews and the `use-mock-data` launch argument.
@available(iOS 26, *)
let previewProduce: [Produce] = [
		Produce(
			id: 0,
			name: "Apples",
			category: .fruit,
			imageName: "Apples",
			description: "",
			months: [.march, .april, .may, .june, .july, .august],
			seasons: [.autumn, .spring],
			liked: true
		),
		Produce(
			id: 1,
			name: "Bananas",
			category: .fruit,
			imageName: "Bananas",
			description: "",
			months: [.april, .august, .december, .january, .june, .september, .february, .august, .july],
			seasons: [.autumn, .spring],
			liked: true
		),
		Produce(
			id: 2,
			name: "Carrots",
			category: .vegetables,
			imageName: "Carrots",
			description: "",
			months: [.april, .august, .december, .january, .june, .september],
			seasons: [.autumn, .spring],
			liked: true
		),
		Produce(
			id: 3,
			name: "Broccoli",
			category: .vegetables,
			imageName: "Broccoli",
			description: "",
			months: [.april, .august, .december, .january, .june, .september, .may],
			seasons: [.autumn, .spring],
			liked: true
		),
		Produce(
			id: 4,
			name: "Spinach",
			category: .vegetables,
			imageName: "Spinach",
			description: "",
			months: [.april, .august, .april, .january, .june, .september],
			seasons: [.autumn, .spring],
			liked: true
		),
		Produce(
			id: 5,
			name: "Tomatoes",
			category: .vegetables,
			imageName: "Tomatoes",
			description: "",
			months: [.april, .august, .december, .january, .september, .february],
			seasons: [.autumn, .spring],
			liked: true
		),
		Produce(
			id: 6,
			name: "Pears",
			category: .fruit,
			imageName: "Pears",
			description: "",
			months: [.february, .march, .april, .may],
			seasons: [.autumn],
			liked: false
		),
		Produce(
			id: 7,
			name: "Lemons",
			category: .fruit,
			imageName: "Lemons",
			description: "",
			months: [.may, .june, .july, .august, .september, .october],
			seasons: [.winter, .spring],
			liked: true
		),
		Produce(
			id: 8,
			name: "Pumpkin",
			category: .vegetables,
			imageName: "Pumpkin",
			description: "",
			months: [.march, .april, .may, .june, .july],
			seasons: [.autumn, .winter],
			liked: false
		),
		Produce(
			id: 9,
			name: "Avocado",
			category: .fruit,
			imageName: "Avocado",
			description: "",
			months: [.september, .october, .november, .december],
			seasons: [.spring, .summer],
			liked: true
		),
		Produce(
			id: 10,
			name: "Basil",
			category: .herbs,
			imageName: "Basil",
			description: "",
			months: [.november, .december, .january, .february],
			seasons: [.summer],
			liked: false
		),
		Produce(
			id: 11,
			name: "Mint",
			category: .herbs,
			imageName: "Mint",
			description: "",
			months: [.october, .november, .december, .january, .february, .march],
			seasons: [.spring, .summer, .autumn],
			liked: true
		),
]
#endif
