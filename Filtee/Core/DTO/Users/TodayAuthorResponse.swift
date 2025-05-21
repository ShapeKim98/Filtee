//
//  TodayAuthorResponse.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

struct TodayAuthorResponse: Decodable, Sendable {
    let author: ProfileResponse
    let filters: [FilterResponse]
}

