//
//  Array+Produce.swift
//  Seasonal
//
//  Created by Clint Thomas on 13/11/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

extension Array where Element == Produce {
    var favouriteIDs: Set<Int> {
        Set(filter(\.isFavourite).map(\.id))
    }

    func partitioned(pinning ids: Set<Int>) -> (pinned: [Produce], unpinned: [Produce]) {
        guard !ids.isEmpty else { return ([], self) }
        var pinned: [Produce] = []
        var unpinned: [Produce] = []
        for item in self {
            if ids.contains(item.id) {
                pinned.append(item)
            } else {
                unpinned.append(item)
            }
        }
        return (pinned, unpinned)
    }

    // Flat, not two sections: rows rebuilt in another section on an off-screen page kept stale hearts.
    func listItems(pinning ids: Set<Int>) -> [ProduceListItem] {
        let sections = partitioned(pinning: ids)
        guard !sections.pinned.isEmpty, !sections.unpinned.isEmpty else { return map(ProduceListItem.produce) }
        return [.header(Strings.PinnedSection.favourites)]
            + sections.pinned.map(ProduceListItem.produce)
            + [.header(Strings.PinnedSection.others)]
            + sections.unpinned.map(ProduceListItem.produce)
    }
}
