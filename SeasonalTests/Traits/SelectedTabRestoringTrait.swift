//
//  SelectedTabRestoringTrait.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 4/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Testing
@testable import Seasonal

/// Puts back the user's stored tab, since tests share the app's `UserDefaults`.
struct SelectedTabRestoringTrait: SuiteTrait, TestTrait, TestScoping {

    func provideScope(for test: Test, testCase: Test.Case?, performing function: @Sendable () async throws -> Void) async throws {
        let original = await GlobalSettings.selectedTab
        do {
            try await function()
            await restore(original)
        } catch {
            await restore(original)
            throw error
        }
    }

    @MainActor
    private func restore(_ tab: StoredSelectedTab) {
        GlobalSettings.selectedTab = tab
    }
}

extension Trait where Self == SelectedTabRestoringTrait {
    static var restoresSelectedTab: Self { Self() }
}
