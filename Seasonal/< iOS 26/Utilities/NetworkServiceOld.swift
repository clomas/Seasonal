//
//  NetworkServiceOld.swift
//  Seasonal
//
//  Created by Clint Thomas on 16/2/21.
//  Copyright © 2021 Clint Thomas. All rights reserved.
//
// thank you - https://stackoverflow.com/questions/59245501/ios13-check-for-internet-connection-instantly

import Foundation
import Network

actor NetworkServiceOld {

	private var monitor: NWPathMonitor?

	weak var delegate: NetworkObserverDelegateOld?

	init(delegate: NetworkObserverDelegateOld) {
		self.delegate = delegate
		Task { await startMonitoring() }
	}

	func stop() {
		monitor?.cancel()
		monitor = nil
	}

	func retry() {
		startMonitoring()
	}

	/// A cancelled `NWPathMonitor` never restarts, so every start needs a new one.
	private func startMonitoring() {
		monitor?.cancel()
		let monitor = NWPathMonitor()
		monitor.pathUpdateHandler = { [weak self] path in
			Task { @MainActor in
				await self?.delegate?.internetStatusDidChange(status: path.status)
			}
		}
		monitor.start(queue: DispatchQueue.global(qos: .background))
		self.monitor = monitor
	}
}
