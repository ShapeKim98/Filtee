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

extension TodayFilterResponseDTO {
    func toModel() -> TodayFilterModel {
        let filtered = self.files.first(where: { $0.contains("filtered") }) ?? self.files.last
        let original = self.files.last(where: { $0.contains("original") }) ?? self.files.first
        
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
