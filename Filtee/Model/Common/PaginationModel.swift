//
//  PaginationModel.swift
//  Filtee
//
//  Created by 김도형 on 7/10/25.
//

import Foundation

import IdentifiedCollections

struct PaginationModel<T: Identifiable & Sendable>: @unchecked Sendable {
    var data: IdentifiedArrayOf<T>
    var nextCursor: String?
    
    init(data: IdentifiedArrayOf<T> = [], nextCursor: String? = nil) {
        self.data = data
        self.nextCursor = nextCursor
    }
}

extension PaginationDTO where T == FilterSummaryResponseDTO {
    func toModel() -> PaginationModel<FilterModel> {
        return PaginationModel(
            data: IdentifiedArrayOf(uniqueElements:  self.data.map { $0.toModel() }),
            nextCursor: self.nextCursor
        )
    }
}
