//
//  CKErrorMessagesTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import CloudKit
import XCTest
@testable import Seasonal

final class CKErrorMessagesTests: XCTestCase {

    func testMessagesByErrorCode() {
        XCTAssertEqual(CKError(.notAuthenticated).errorMessage, Strings.CloudError.notSignedIn)
        XCTAssertEqual(CKError(.networkFailure).errorMessage, Strings.CloudError.network)
        XCTAssertEqual(CKError(.networkUnavailable).errorMessage, Strings.CloudError.network)
        XCTAssertEqual(CKError(.quotaExceeded).errorMessage, Strings.CloudError.storageFull)
        XCTAssertEqual(CKError(.serviceUnavailable).errorMessage, Strings.CloudError.unavailable)
        XCTAssertEqual(CKError(.internalError).errorMessage, Strings.CloudError.unavailable)
    }

    func testTitleIsTheSameForEveryError() {
        XCTAssertEqual(CKError(.notAuthenticated).errorTitle, Strings.CloudError.title)
        XCTAssertEqual(CKError(.internalError).errorTitle, Strings.CloudError.title)
    }
}
