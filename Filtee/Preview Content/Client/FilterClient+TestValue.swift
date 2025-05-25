//
//  FilterClient+TestValue.swift
//  Filtee
//
//  Created by 김도형 on 5/22/25.
//

import Foundation

extension FilterClient {
    static let testValue = {
        return FilterClient(
            hotTrend: { FilterResponse.hotTrendMock.map { $0.toModel() } },
            todayFilter: { TodayFilterResponse.mock.toModel() }
        )
    }()
}
