//
//  PaymentsClient.swift
//  Filtee
//
//  Created by 김도형 on 6/16/25.
//

import SwiftUICore

struct PaymentsClient {
    var paymentsValidation: @Sendable (
        _ impUid: String
    ) async throws -> Void
}

extension PaymentsClient: EnvironmentKey, NetworkClientConfigurable {
    typealias E = PaymentsEndpoint
    
    static let defaultValue: PaymentsClient = {
        return PaymentsClient(
            paymentsValidation: { impUid in
                try await request(.paymentsValidation(impUid: impUid))
            }
        )
    }()
}

extension EnvironmentValues {
    var paymentsClient: PaymentsClient {
        get { self[PaymentsClient.self] }
        set { self[PaymentsClient.self] = newValue }
    }
}
