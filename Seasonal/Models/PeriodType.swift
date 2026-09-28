//
//  PeriodType.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

/// `Sendable` because a period is created in the pager's cell builder and handed to `ProduceStore`.
protocol PeriodType: CaseIterable, Hashable, Sendable where AllCases == [Self] {
    static var currentPeriod: Self { get }

    var title: String { get }
    var index: Int { get }
    var cacheKey: ProduceCacheKey { get }

    func contains(_ produce: Produce) -> Bool
}
