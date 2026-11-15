//
//  UserDefaultsBoolDefaultTests.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 13/11/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Foundation
import Testing
@testable import Seasonal

final class UserDefaultsBoolDefaultTests {

    private let suiteName = "UserDefaultsBoolDefaultTests.\(UUID().uuidString)"
    private let key = "testFlag.\(UUID().uuidString)"
    private let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: suiteName))
    }

    deinit {
        defaults.removePersistentDomain(forName: suiteName)
    }

    @Test(arguments: [true, false])
    func missingValueUsesDefault(_ defaultValue: Bool) {
        #expect(defaults.bool(forKey: key, default: defaultValue) == defaultValue)
    }

    @Test(arguments: ["YES", "true", "1"])
    func launchArgumentStringsEnable(_ value: String) {
        defaults.set(value, forKey: key)

        #expect(defaults.bool(forKey: key, default: false))
    }

    @Test(arguments: ["NO", "false", "0"])
    func launchArgumentStringsDisable(_ value: String) {
        defaults.set(value, forKey: key)

        #expect(!defaults.bool(forKey: key, default: true))
    }

    @Test(arguments: [true, false])
    func storedBoolIsRead(_ value: Bool) {
        defaults.set(value, forKey: key)

        #expect(defaults.bool(forKey: key, default: !value) == value)
    }
}
