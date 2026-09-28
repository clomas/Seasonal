//
//  CKError+Messages.swift
//  Seasonal
//
//  Created by Clint Thomas on 14/6/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import CloudKit

extension CKError {

    var errorTitle: String {
        Strings.CloudError.title
    }

    var errorMessage: String {
        switch code {
        case .notAuthenticated: Strings.CloudError.notSignedIn
        case .networkFailure, .networkUnavailable: Strings.CloudError.network
        case .quotaExceeded: Strings.CloudError.storageFull
        default: Strings.CloudError.unavailable
        }
    }
}
