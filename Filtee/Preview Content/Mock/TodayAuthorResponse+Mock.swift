//
//  TodayAuthorResponse+Mock.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

extension TodayAuthorResponse {
    static let mock = TodayAuthorResponse(
        author: .creatorMock,
        filters: FilterResponse.hotTrendMock
    )
}
