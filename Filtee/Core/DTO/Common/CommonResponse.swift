//
//  CommonResponse.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import Foundation

struct CommonResponse: Decodable {
    let message: String
}

extension CommonResponse {
    func toModel() -> CommonModel {
        return CommonModel(message: self.message)
    }
}
