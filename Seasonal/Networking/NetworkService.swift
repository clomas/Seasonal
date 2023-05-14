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

protocol NetworkObserver: AnyObject {
	func internetStatusDidChange(status: NWPath.Status)
}

final class NetworkService {

	private static let sharedInstance = NetworkService()

	var currentStatus: NWPath.Status {
		return monitor.currentPath.status
	}
	var networkUpdate: ((Bool) -> Void)?

	private var monitor = NWPathMonitor()
	private var observations = [ObjectIdentifier: NetworkChangeObservation]()

	init() {
		startMonitoring()
	}

	class func instance() -> NetworkService {
		return sharedInstance
	}

	struct NetworkChangeObservation {
		weak var observer: NetworkObserver?
	}

	func startMonitoring() {
		monitor.pathUpdateHandler = { [weak self] path in
			guard let observations = self?.observations else { return }

			for (id, observations) in observations {

				// If any observer is nil, remove it from the list of observers
				guard let observer = observations.observer else {
					self?.observations.removeValue(forKey: id)
					continue
				}

				DispatchQueue.main.async(execute: {
					observer.internetStatusDidChange(status: path.status)
				})
			}
		}
		monitor.start(queue: DispatchQueue.global(qos: .background))
	}

	func internetStatusDidChange(status: NWPath.Status) {
		var internetStatus = false

		switch status {
		case .satisfied:
			internetStatus = true
		case .unsatisfied:
			internetStatus = false
		default:
			internetStatus = false
		}
		if let networkUpdateCallback = networkUpdate {
			// callback to viewModel
			networkUpdateCallback(internetStatus)
		}
	}

	func removeObserver(observer: NetworkObserver) {
		let id = ObjectIdentifier(observer)
		observations.removeValue(forKey: id)
	}
}
