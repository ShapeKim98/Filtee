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
    let original: String
    let filtered: String
    let photoMetadata: PhotoMetadataDTO?
    let filterValues: FilterValuesDTO?
    let price: Int
}
