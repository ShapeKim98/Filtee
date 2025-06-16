//
//  IamportClient.swift
//  Filtee
//
//  Created by 김도형 on 6/16/25.
//

import SwiftUICore
import WebKit

@preconcurrency import iamport_ios

struct IamportClient {
    var requestIamport: @Sendable () async throws -> IamportModel?
    var requestPayment: @Sendable (
        _ wkWebView: WKWebView,
        _ payload: IamportPaymentPayloadModel
    ) async -> Void
    var close: @Sendable () async -> Void
}

extension IamportClient: EnvironmentKey {
    static let defaultValue: IamportClient = {
        let manager = IamportManager()
        
        return IamportClient(
            requestIamport: {
                let response = try await manager.requestIamport()
                return response?.toModel()
            },
            requestPayment: { wkWebView, payload in
                manager.requestPayment(
                    wkWebView: wkWebView,
                    orderCode: payload.orderCode,
                    price: payload.price,
                    name: payload.name,
                    buyerName: payload.buyerName
                )
            },
            close: {
                manager.close()
            }
        )
    }()
}

extension EnvironmentValues {
    var iamportClient: IamportClient {
        get { self[IamportClient.self] }
        set { self[IamportClient.self] = newValue }
    }
}
