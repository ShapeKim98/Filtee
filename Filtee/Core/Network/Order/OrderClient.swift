//
//  OrderClient.swift
//  Filtee
//
//  Created by 김도형 on 6/16/25.
//

import SwiftUICore

struct OrderClient {
    var ordersCreate: @Sendable(
        _ filterId: String,
        _ totalPrice: Int
    ) async throws -> OrderCreateModel
}

extension OrderClient: EnvironmentKey, NetworkClientConfigurable {
    typealias E = OrderEndpoint
    
    static let defaultValue: OrderClient = {
        return OrderClient(
            ordersCreate: { filterId, totalPrice in
                let requestModel = OrderCreateRequest(
                    filterId: filterId,
                    totalPrice: totalPrice
                )
                let response: OrderCreateResponseDTO = try await request(.ordersCreate(requestModel))
                return response.toModel()
            }
        )
    }()
}

extension EnvironmentValues {
    var orderClient: OrderClient {
        get { self[OrderClient.self] }
        set { self[OrderClient.self] = newValue }
    }
}
