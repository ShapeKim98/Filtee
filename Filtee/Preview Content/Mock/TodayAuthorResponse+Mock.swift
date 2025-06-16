//
//  TodayAuthorResponse+Mock.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

extension TodayAuthorResponseDTO {
    static let mock = TodayAuthorResponseDTO(
        author: .creatorMock,
        filters: FilterSummaryResponseDTO.hotTrendMock
    )
}
