//
//  FilterDetailModel.swift
//  Filtee
//
//  Created by 김도형 on 5/25/25.
//

import Foundation

struct FilterDetailModel {
    let id: String
    let category: String?
    let title: String
    let description: String
    let original: String?
    let filtered: String?
    var creator: ProfileModel
    var isLike: Bool
    var likeCount: Int
    var buyerCount: Int
    let createdAt: String
    let updatedAt: String
    let photoMetadata: PhotoMetadataModel?
    let filterValues: FilterValuesModel
    let isDownloaded: Bool
    let price: Int
}

extension FilterResponseDTO {
    func toModel() -> FilterDetailModel {
        let filtered = self.files.first(where: { $0.contains("filtered") }) ?? self.files.last
        let original = self.files.last(where: { $0.contains("original") }) ?? self.files.first
        
        return FilterDetailModel(
            id: self.filterId,
            category: self.category,
            title: self.title,
            description: self.description,
            original: original?.imageURL,
            filtered: filtered?.imageURL,
            creator: self.creator.toModel(),
            isLike: self.isLike,
            likeCount: self.likeCount,
            buyerCount: self.buyerCount,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            photoMetadata: self.photoMetadata?.toModel(),
            filterValues: self.filterValues.toModel(),
            isDownloaded: self.isDownloaded,
            price: self.price
        )
    }
}
