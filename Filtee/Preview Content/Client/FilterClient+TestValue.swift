//
//  FilterClient+TestValue.swift
//  Filtee
//
//  Created by 김도형 on 5/22/25.
//

import Foundation

import IdentifiedCollections

extension FilterClient {
    static let testValue = {
        return FilterClient(
            hotTrend: { FilterSummaryResponseDTO.hotTrendMock.map { $0.toModel() } },
            todayFilter: { TodayFilterResponseDTO.mock.toModel() },
            filterDetail: { _ in FilterResponseDTO.detailMock.toModel() },
            filterLike: { _, isLike in !isLike },
            files: { _ in [] },
            filters: { _ in },
            users: { _, _, _, _ in
                let list = FilterSummaryResponseDTO.hotTrendMock.map { $0.toModel() }
                let array = IdentifiedArrayOf<FilterModel>(uniqueElements: list)
                return PaginationModel(data: array, nextCursor: "")
            }
        )
    }()
}
