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
	coord.state = .locationNotFound
	coord.produceData = [
		Produce(
			id: 0,
			name: "Apples",
			category: .fruit,
			imageName: "Apples",
			description: "",
			months: [.march],
			seasons: [.autumn, .spring],
			liked: true
		),
		Produce(
			id: 1,
			name: "Bananas",
			category: .fruit,
			imageName: "Bananas",
			description: "",
			months: [.april, .august, .december, .january, .june, .september, .february],
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
			id: 0,
			name: "Apples",
			category: .fruit,
			imageName: "Apples",
			description: "",
			months: [.june, .september, .july, .april, .february, .may, .march],
			seasons: [.autumn, .spring],
			liked: true
		),
		Produce(
			id: 1,
			name: "Bananas",
			category: .fruit,
			imageName: "Bananas",
			description: "",
			months: [.april, .august, .december, .january, .june, .september, .february],
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
	]
	return coord
}()

#endif
