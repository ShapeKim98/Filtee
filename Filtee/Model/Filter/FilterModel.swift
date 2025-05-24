//
//  FilterModel.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

struct FilterModel: Identifiable, Hashable {
    static func == (lhs: FilterModel, rhs: FilterModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: String
    let category: String
    let title: String
    let description: String
    let creator: ProfileModel
    let isLike: Bool
    let likeCount: Int
    let buyerCount: Int
    let createdAt: String
    let updatedAt: String
    let original: String?
    let filtered: String?
}

extension FilterResponse {
    func toModel() -> FilterModel {
        let original = self.files.first
        let filtered = self.files.last
        
        return FilterModel(
            id: self.filterId,
            category: self.category,
            title: self.title,
            description: self.description,
            creator: self.creator.toModel(),
            isLike: self.isLike,
            likeCount: self.likeCount,
            buyerCount: self.buyerCount,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            original: original?.imageURL,
            filtered: filtered?.imageURL
        )
    }
}
