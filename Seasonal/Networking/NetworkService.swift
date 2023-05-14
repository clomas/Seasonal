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

protocol NetworkObserverDelegate: AnyObject {
	func internetStatusDidChange(status: NWPath.Status)
}

final class NetworkService {

	private var monitor: NWPathMonitor = NWPathMonitor()

	weak var delegate: NetworkObserverDelegate?

	init(delegate: NetworkObserverDelegate) {
		self.delegate = delegate

		startMonitoring()
	}

	func stop() {
		monitor.cancel()
	}

	private func startMonitoring() {
		monitor.pathUpdateHandler = { [weak self] path in

			DispatchQueue.main.asyncAfter(deadline: .now(), execute: { [weak self] in
				self?.internetStatusDidChange(status: path.status)
			})
		}
		monitor.start(queue: DispatchQueue.global(qos: .background))
	}

	private func internetStatusDidChange(status: NWPath.Status) {
		delegate?.internetStatusDidChange(status: status)
	}
}
