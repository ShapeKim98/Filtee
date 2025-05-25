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
    let original: String?
    let filtered: String?
}

extension TodayFilterResponse {
    func toModel() -> TodayFilterModel {
        let original = self.files.first
        let filtered = self.files.last
        
        return TodayFilterModel(
            id: self.filterId,
            title: self.title,
            introduction: self.introduction,
            description: self.description,
            original: original?.imageURL,
            filtered: filtered?.imageURL
        )
    }
}
