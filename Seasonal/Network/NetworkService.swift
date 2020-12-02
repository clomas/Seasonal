//
//  NewtworkService.swift
//  Seasonal
//
//  Created by Clint Thomas on 31/7/20.
//  Copyright © 2020 Clint Thomas. All rights reserved.
//
// thank you - https://stackoverflow.com/questions/59245501/ios13-check-for-internet-connection-instantly

import Foundation
import Network

protocol NetworkCheckObserver: class {
    func internetStatusDidChange(status: NWPath.Status)
}

class NetworkService {

    struct NetworkChangeObservation {
        weak var observer: NetworkCheckObserver?
    }

    private var monitor = NWPathMonitor()
    private static let _sharedInstance = NetworkService()
    private var observations = [ObjectIdentifier: NetworkChangeObservation]()
    var currentStatus: NWPath.Status {
        get {
            return monitor.currentPath.status
        }
    }

    class func sharedInstance() -> NetworkService {
        return _sharedInstance
    }

    init() {
        monitor.pathUpdateHandler = { [unowned self] path in
            for (id, observations) in self.observations {

                // If any observer is nil, remove it from the list of observers
                guard let observer = observations.observer else {
                    self.observations.removeValue(forKey: id)
                    continue
                }

                DispatchQueue.main.async(execute: {
                    observer.internetStatusDidChange(status: path.status)
                })
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }

    func addObserver(observer: NetworkCheckObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = NetworkChangeObservation(observer: observer)
    }

    func removeObserver(observer: NetworkCheckObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
}

