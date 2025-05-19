//
//  UserClient.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import SwiftUICore

struct UserClient {
    var validationEmail: @Sendable (
        _ email: String
    ) async throws -> Void
    var join: @Sendable (
        _ model: JoinModel
    ) async throws -> Void
    var emailLogin: @Sendable (
        _ model: EmailLoginModel
    ) async throws -> Void
    var kakaoLogin: @Sendable (
        _ model: KakaoLoginModel
    ) async throws -> Void
    var appleLogin: @Sendable (
        _ model: AppleLoginModel
    ) async throws -> Void
    var deviceToken: @Sendable (
        _ deviceToken: String
    ) async throws -> Void
}

extension UserClient: EnvironmentKey, NetworkClientConfigurable {
    typealias E = UserEndpoint
    
    static let defaultValue: UserClient = {
        return UserClient(
            validationEmail: { email in
                try await requestNonToken(.validationEmail(email: email))
            },
            join: { model in
                let request = model.toData()
                try await requestNonToken(.join(request))
            },
            emailLogin: { model in
                let request = model.toData()
                try await requestNonToken(.login(request))
            },
            kakaoLogin: { model in
                let request = model.toData()
                try await requestNonToken(.kakoLogin(request))
            },
            appleLogin: { model in
                let request = model.toData()
                try await requestNonToken(.appleLogin(request))
            },
            deviceToken: { deviceToken in
                try await requestNonToken(.deviceToken(deviceToken: deviceToken))
            }
        )
    }()
    
    static let testValue: UserClient = {
        return UserClient(
            validationEmail: { _ in },
            join: { _ in },
            emailLogin: { _ in },
            kakaoLogin: { _ in },
            appleLogin: { _ in },
            deviceToken: { _ in }
        )
    }()
}

extension EnvironmentValues {
    var userClient: UserClient {
        get { self[UserClient.self] }
        set { self[UserClient.self] = newValue }
    }
}
