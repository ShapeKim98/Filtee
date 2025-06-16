//
//  OrderCreateModel.swift
//  Filtee
//
//  Created by 김도형 on 6/16/25.
//

import Foundation

struct OrderCreateModel {
    let orderId: String
    let orderCode: String
    let totalPrice: Int
    let createdAt: String
    let updatedAt: String
}

extension OrderCreateResponseDTO {
    func toModel() -> OrderCreateModel {
        return OrderCreateModel(
            orderId: self.orderId,
            orderCode: self.orderCode,
            totalPrice: self.totalPrice,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
