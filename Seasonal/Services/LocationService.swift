//
//  LocationService.swift
//  Seasonal
//
//  Created by Clint Thomas on 6/8/19.
//  Copyright © 2019 Clint Thomas. All rights reserved.
//

import CoreLocation

@available(iOS 26, *)
struct LocationService: Sendable {

    func currentLocation() async -> CLLocation? {
        let session = CLServiceSession(authorization: .whenInUse)
        defer { session.invalidate() }

        do {
            for try await update in CLLocationUpdate.liveUpdates() {
                if let location = update.location {
                    return location
                }
                if update.authorizationDenied || update.authorizationDeniedGlobally
                    || update.authorizationRestricted || update.locationUnavailable {
                    return nil
                }
            }
        } catch {
            return nil
        }
        return nil
    }
}
