//
//  _NetworkService.swift
//  Seasonal
//
//  Created by Clint Thomas on 16/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//
// thank you - https://stackoverflow.com/questions/59245501/ios13-check-for-internet-connection-instantly

import Foundation
import Network

@MainActor
protocol NetworkObserverDelegate: AnyObject, Sendable {
	func internetStatusDidChange(status: NWPath.Status)
}

actor NetworkService {

	private let monitor: NWPathMonitor = NWPathMonitor()

	weak var delegate: NetworkObserverDelegate?

	init(delegate: NetworkObserverDelegate) {
		self.delegate = delegate

		Task {
			await startMonitoring()
		}
	}

	func stop() {
		monitor.cancel()
	}

	func retry() async {
		monitor.cancel()
		await startMonitoring()
	}

	func startMonitoring() async {
		monitor.pathUpdateHandler = { [weak self] path in
			Task { @MainActor in
				await self?.delegate?.internetStatusDidChange(status: path.status)
			}
		}
		monitor.start(queue: DispatchQueue.global(qos: .background))
	}
}
