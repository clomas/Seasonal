//
//  CKErrorMessagesTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import CloudKit
import Testing
@testable import Seasonal

struct CKErrorMessagesTests {

    @Test(arguments: [
        (CKError.Code.notAuthenticated, Strings.CloudError.notSignedIn),
        (.networkFailure, Strings.CloudError.network),
        (.networkUnavailable, Strings.CloudError.network),
        (.quotaExceeded, Strings.CloudError.storageFull),
        (.serviceUnavailable, Strings.CloudError.unavailable),
        (.internalError, Strings.CloudError.unavailable)
    ])
    func messageForErrorCode(_ code: CKError.Code, expected: String) {
        #expect(CKError(code).errorMessage == expected)
    }

    @Test(arguments: [CKError.Code.notAuthenticated, .networkFailure, .quotaExceeded, .internalError])
    func titleIsTheSameForEveryError(_ code: CKError.Code) {
        #expect(CKError(code).errorTitle == Strings.CloudError.title)
    }
}
