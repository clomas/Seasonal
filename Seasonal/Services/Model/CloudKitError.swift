//
//  CloudKitError.swift
//  Seasonal
//
//  Created by Clint Thomas on 6/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import CloudKit

enum CloudKitError: LocalizedError, Equatable {
    
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

    var errorTitle: String {
        "iCloud Error"
    }
    
    var errorMessage: String {
        switch self {
        case .notAuthenticated, .noToken:   "Your data is stored privately in your own iCloud. Open Settings to sign in."
        case .networkUnavailable:           "Check your network and try again."
        case .quotaExceeded:                "Free up iCloud storage to continue."
        case .serviceUnavailable:           "iCloud is temporarily unavailable. Try again later."
        case .databaseError:                "Couldn't load produce data. Try again later."
        case .invalidID:                    "Couldn't update the favourite. Try again later."
        case .likesError:                   "Couldn't save your favourite. Try again later."
        case .unknown:                      "Try again later."
        }
    }
    
    static func == (lhs: CloudKitError, rhs: CloudKitError) -> Bool {
        switch (lhs, rhs) {
        case (.notAuthenticated, .notAuthenticated),
             (.networkUnavailable, .networkUnavailable),
             (.quotaExceeded, .quotaExceeded),
             (.serviceUnavailable, .serviceUnavailable),
             (.databaseError, .databaseError),
             (.invalidID, .invalidID),
             (.likesError, .likesError),
             (.noToken, .noToken):
            return true
        case (.unknown(let l), .unknown(let r)):
            return l.localizedDescription == r.localizedDescription
        default:
            return false
        }
    }
}
