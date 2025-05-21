//
//  FilterModel.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

struct FilterModel: Identifiable {
    let id: String
    let category: String
    let title: String
    let description: String
    let files: [String]
    let creator: ProfileModel
    let isLike: Bool
    let likeCount: Int
    let buyerCount: Int
    let createdAt: String
    let updatedAt: String
}

extension FilterResponse {
    func toModel() -> FilterModel {
        return FilterModel(
            id: self.filterId,
            category: self.category,
            title: self.title,
            description: self.description,
            files: self.files.map(\.imageURL),
            creator: self.creator.toModel(),
            isLike: self.isLike,
            likeCount: self.likeCount,
            buyerCount: self.buyerCount,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
