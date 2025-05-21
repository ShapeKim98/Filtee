//
//  TodayFilterModel.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

struct TodayFilterModel: Identifiable {
    let id: String
    let title: String
    let introduction: String
    let description: String
    let files: [String]
}

extension TodayFilterResponse {
    func toModel() -> TodayFilterModel {
        return TodayFilterModel(
            id: self.filterId,
            title: self.title,
            introduction: self.introduction,
            description: self.description,
            files: self.files.map(\.imageURL)
        )
    }
}
