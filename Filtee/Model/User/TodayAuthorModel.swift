//
//  TodayAuthorModel.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

struct TodayAuthorModel {
    let author: ProfileModel
    let filters: [FilterModel]
}

extension TodayAuthorResponse {
    func toModel() -> TodayAuthorModel {
        return TodayAuthorModel(
            author: self.author.toModel(),
            filters: self.filters.map { $0.toModel() }
        )
    }
}
