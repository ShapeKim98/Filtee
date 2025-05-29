//
//  TodayAuthorResponse.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

struct TodayAuthorResponseDTO: ResponseDTO {
    let author: UserInfoResponseDTO
    let filters: [FilterSummaryResponseDTO]
}

