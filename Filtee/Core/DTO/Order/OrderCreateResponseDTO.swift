//
//  OrderCreateResponseDTO.swift
//  Filtee
//
//  Created by 김도형 on 6/16/25.
//

import Foundation

struct OrderCreateResponseDTO: ResponseDTO {
    let orderId: String
    let orderCode: String
    let totalPrice: Int
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case orderCode = "order_code"
        case totalPrice = "total_price"
        case createdAt
        case updatedAt
    }
}
