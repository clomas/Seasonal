//
//  NetworkObserverDelegate.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Network

@MainActor
protocol NetworkObserverDelegate: AnyObject, Sendable {
	func internetStatusDidChange(status: NWPath.Status)
}
