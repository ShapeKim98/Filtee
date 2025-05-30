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
    var original: String = ""
    var filtered: String = ""
    var photoMetadata: PhotoMetadataModel? = nil
    var filterValues: FilterValuesModel = FilterValuesModel()
    var price: Int = 0
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
