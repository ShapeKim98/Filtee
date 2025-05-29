//
//  FilterDetailResponse.swift
//  Filtee
//
//  Created by 김도형 on 5/25/25.
//

import Foundation

struct FilterResponseDTO: ResponseDTO {
    let filterId: String
    let category: String?
    let title: String
    let description: String
    let files: [String]
    let creator: UserInfoResponseDTO
    let isLike: Bool
    let likeCount: Int
    let buyerCount: Int
    let createdAt: String
    let updatedAt: String
    let photoMetadata: PhotoMetadataDTO?
    let filterValues: FilterValuesDTO
    let isDownloaded: Bool
    let price: Int
    
    enum CodingKeys: String, CodingKey {
        case filterId = "filter_id"
        case category
        case title
        case description
        case files
        case creator
        case isLike = "is_liked"
        case likeCount = "like_count"
        case buyerCount = "buyer_count"
        case createdAt
        case updatedAt
        case photoMetadata
        case filterValues
        case isDownloaded = "is_downloaded"
        case price
    }
}
