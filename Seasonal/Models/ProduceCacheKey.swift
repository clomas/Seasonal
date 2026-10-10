//
//  ProduceCacheKey.swift
//  Seasonal
//
//  Created by Clint Thomas on 28/9/2026.
//  Copyright © 2026 Clint Thomas. All rights reserved.
//

enum ProduceCacheKey: Hashable {
	case favourites
	case month(Months)
	case season(Seasons)
}
