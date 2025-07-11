//
//  FilterResponse.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

struct FilterSummaryResponseDTO: ResponseDTO {
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
    }
}
