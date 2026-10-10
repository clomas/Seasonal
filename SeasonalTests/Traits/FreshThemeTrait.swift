//
//  FreshThemeTrait.swift
//  SeasonalTests
//
//  Created by Clint Thomas on 9/10/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

import Testing
@testable import Seasonal

/// Renders in the default theme whatever the simulator last stored, then puts the stored one back.
struct FreshThemeTrait: SuiteTrait, TestScoping {

    func provideScope(for test: Test, testCase: Test.Case?, performing function: @Sendable () async throws -> Void) async throws {
        let original = await setTheme(.fresh)
        do {
            try await function()
            await setTheme(original)
        } catch {
            await setTheme(original)
            throw error
        }
    }

    @MainActor
    @discardableResult
    private func setTheme(_ theme: Theme) -> Theme {
        let previous = ThemeStore.shared.theme
        ThemeStore.shared.theme = theme
        return previous
    }
}

extension Trait where Self == FreshThemeTrait {
    static var freshTheme: Self { Self() }
}
