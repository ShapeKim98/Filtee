//
//  FilterMakeModel.swift
//  Filtee
//
//  Created by 김도형 on 5/29/25.
//

import Foundation

struct FilterMakeModel {
    var category: String?
    var title: String = ""
    var description: String = ""
    var files: [String] = []
    var photoMetadata: PhotoMetadataModel? = nil
    var filterValues: FilterValuesModel = FilterValuesModel()
    var price: Int = 0
}

extension FilterMakeModel {
    func toData() -> FilterMakeRequest {
        return FilterMakeRequest(
            category: self.category ?? "",
            title: self.title,
            description: self.description,
            files: self.files,
            photoMetadata: self.photoMetadata?.toData(),
            filterValues: self.filterValues.toData(),
            price: self.price
        )
    }
}

extension FilterMakeModel {
    enum Category: String, CaseIterable {
        case 푸드
        case 인물
        case 풍경
        case 야경
        case 별
    }
}
