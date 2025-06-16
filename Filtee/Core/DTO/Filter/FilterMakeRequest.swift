//
//  FilterMakeRequest.swift
//  Filtee
//
//  Created by 김도형 on 5/29/25.
//

import Foundation

struct FilterMakeRequest: RequestDTO {
    let category: String
    let title: String
    let description: String
    let files: [String]
    let photoMetadata: PhotoMetadataDTO?
    let filterValues: FilterValuesDTO
    let price: Int
    
    enum CodingKeys: String, CodingKey {
        case category
        case title
        case description
        case files
        case photoMetadata = "photo_metadata"
        case filterValues = "filter_values"
        case price
    }
}
