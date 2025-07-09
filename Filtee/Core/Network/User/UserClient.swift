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
    var logout: @Sendable () -> Void
    var todayAuthor: @Sendable () async throws -> TodayAuthorModel
    var meProfile: @Sendable () async throws -> MyInfoModel
}

extension UserClient: EnvironmentKey, NetworkClientConfigurable {
    typealias E = UserEndpoint
    
    static let defaultValue: UserClient = {
        let keychainManager = KeychainManager.shared
        
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
                let response: LoginDTO = try await requestNonToken(.login(request))
                keychainManager.save(
                    response.accessToken,
                    key: .accessToken
                )
                keychainManager.save(
                    response.refreshToken,
                    key: .refreshToken
                )
                let _: MyInfoResponseDTO = try await Self.request(.meProfile)
                return
            },
            kakaoLogin: { model in
                let request = model.toData()
                let response: LoginDTO = try await requestNonToken(.kakoLogin(request))
                keychainManager.save(
                    response.accessToken,
                    key: .accessToken
                )
                keychainManager.save(
                    response.refreshToken,
                    key: .refreshToken
                )
                let _: MyInfoResponseDTO = try await Self.request(.meProfile)
            },
            appleLogin: { model in
                let request = model.toData()
                let response: LoginDTO = try await requestNonToken(.appleLogin(request))
                keychainManager.save(
                    response.accessToken,
                    key: .accessToken
                )
                keychainManager.save(
                    response.refreshToken,
                    key: .refreshToken
                )
                let _: MyInfoResponseDTO = try await Self.request(.meProfile)
            },
            deviceToken: { deviceToken in
                try await requestNonToken(.deviceToken(deviceToken: deviceToken))
            },
            logout: {
                keychainManager.delete(.accessToken)
                keychainManager.delete(.refreshToken)
                URLCache.shared.removeAllCachedResponses()
            },
            todayAuthor: {
                let response: TodayAuthorResponseDTO = try await request(.todayAuthor)
                return response.toModel()
            },
            meProfile: {
                let response: MyInfoResponseDTO = try await request(.meProfile)
                return response.toModel()
            }
        )
    }()
}

extension EnvironmentValues {
    var userClient: UserClient {
        get { self[UserClient.self] }
        set { self[UserClient.self] = newValue }
    }
}
