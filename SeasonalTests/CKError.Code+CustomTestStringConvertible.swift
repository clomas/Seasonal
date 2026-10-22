//
//  CKError.Code+CustomTestStringConvertible.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 4/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import CloudKit
import Testing

extension CKError.Code: @retroactive CustomTestStringConvertible {
    public var testDescription: String {
        switch self {
        case .notAuthenticated: ".notAuthenticated"
        case .networkFailure: ".networkFailure"
        case .networkUnavailable: ".networkUnavailable"
        case .quotaExceeded: ".quotaExceeded"
        case .serviceUnavailable: ".serviceUnavailable"
        case .internalError: ".internalError"
        default: "CKError.Code(rawValue: \(rawValue))"
        }
    }
}
