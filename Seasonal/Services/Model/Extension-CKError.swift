//
//  CloudKitError.swift
//  Seasonal
//
//  Created by Clint Thomas on 6/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import CloudKit

extension CKError {

    enum Category {
        case notAuthenticated
        case network
        case rateLimited
        case quota
        case server
        case unknown
    }

    var category: Category {
        switch self.code {
        case .notAuthenticated:
            .notAuthenticated
        case .networkFailure, .networkUnavailable:
            .network
        case .requestRateLimited:
            .rateLimited
        case .quotaExceeded:
            .quota
        case .serviceUnavailable, .zoneBusy:
            .server
        default:
            .unknown
        }
    }
    
    var errorTitle: String {
        "iCloud Error"
    }
    
    var errorMessage: String {
        return switch category {
        case .notAuthenticated:
            "Your data is stored privately in your own iCloud. Open Settings to sign in."
        case .network:
            "Check your network and try again."
        case .quota:
            "Free up iCloud storage to continue."
        default:
            "iCloud is temporarily unavailable. Try again later."
        }
    }
}
