//
//  CloudKitError.swift
//  Seasonal
//
//  Created by Clint Thomas on 6/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import CloudKit

enum CloudKitError: LocalizedError {
    case notAuthenticated
    case networkUnavailable
    case quotaExceeded
    case serviceUnavailable
    case databaseError
    case invalidID
    case likesError
    case noToken
    case unknown(Error)

    init(_ error: Error) {
        guard let ckError = error as? CKError else {
            self = .unknown(error)
            return
        }
        switch ckError.code {
        case .notAuthenticated, .accountTemporarilyUnavailable:
            self = .notAuthenticated
        case .networkUnavailable, .networkFailure:
            self = .networkUnavailable
        case .quotaExceeded:
            self = .quotaExceeded
        case .serviceUnavailable, .requestRateLimited, .zoneBusy:
            self = .serviceUnavailable
        default:
            self = .unknown(ckError)
        }
    }

    var errorDescription: String {
        switch self {
        case .notAuthenticated, .noToken:
            "Sign in to iCloud in Settings to sync your favourites."
        case .networkUnavailable:
            "No internet connection. Check your network and try again."
        case .quotaExceeded:
            "Your iCloud storage is full."
        case .serviceUnavailable:
            "iCloud is temporarily unavailable. Try again later."
        case .databaseError:
            "Couldn't load produce data. Try again later."
        case .invalidID:
            "Couldn't update the favourite."
        case .likesError:
            "Couldn't save your favourite. Try again later."
        default:
            "Something went wrong. Try again later."
        }
    }
}
