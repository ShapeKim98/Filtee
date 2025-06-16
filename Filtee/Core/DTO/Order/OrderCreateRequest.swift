//
//  OrderRequest.swift
//  Filtee
//
//  Created by 김도형 on 6/16/25.
//

import Foundation

struct OrderCreateRequest: RequestDTO {
    let filterId: String
    let totalPrice: Int
    
    enum CodingKeys: String, CodingKey {
        case filterId = "filter_id"
        case totalPrice = "total_price"
    }
}
