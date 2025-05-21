//
//  FilterResponse.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

struct FilterResponse: ResponseData {
    let filterId: String
    let category: String
    let title: String
    let description: String
    let files: [String]
    let creator: ProfileResponse
    let isLike: Bool
    let likeCount: Int
    let buyerCount: Int
    let createdAt: String
    let updatedAt: String
}
