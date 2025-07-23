//
//  PushClient.swift
//  Filtee
//
//  Created by 김도형 on 7/23/25.
//

import SwiftUICore

struct PushClient {
    var notificationsPushGroup: @Sendable(
        _ model: PushModel
    ) async throws -> Void
}

extension PushClient: EnvironmentKey, NetworkClientConfigurable {
    typealias E = PushEndpoint
    
    static let defaultValue: PushClient = {
        return PushClient(
            notificationsPushGroup: { model in
                let parameters = model.toData()
                try await request(.notificationsPushGroup(parameters))
            }
        )
    }()
}

extension EnvironmentValues {
    var pushClient: PushClient {
        get { self[PushClient.self] }
        set { self[PushClient.self] = newValue }
    }
}
