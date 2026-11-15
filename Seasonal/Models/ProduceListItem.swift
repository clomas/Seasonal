//
//  ProduceListItem.swift
//  Seasonal
//
//  Created by Clint Thomas on 14/11/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

enum ProduceListItem: Identifiable {
    case header(String)
    case produce(Produce)

    var id: String {
        switch self {
        case let .header(title): "header.\(title)"
        case let .produce(produce): "produce.\(produce.id)"
        }
    }
}
