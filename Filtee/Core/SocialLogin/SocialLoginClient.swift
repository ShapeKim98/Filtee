//
//  SocialLoginClient.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import SwiftUICore

struct SocialLoginClient: Sendable {
    var kakaoLogin: @Sendable () async throws -> SocialLoginModel
    var appleLogin: @Sendable () async throws -> SocialLoginModel
    var appleToken: @Sendable () async throws -> Void
    var appleRevoke: @Sendable () async throws -> Void
    var withdrawKakao: @Sendable () async -> Void
}

extension SocialLoginClient: EnvironmentKey, NetworkClientConfigurable {
    typealias E = SocialLoginEndpoint
    
    static let defaultValue: SocialLoginClient = {
        let manager = SocialLoginManager()
        let keychainManager = KeychainManager.shared
        
        return SocialLoginClient(
            kakaoLogin: { try await manager.kakaoLogin().toModel() },
            appleLogin: {
                let response = try await manager.appleLogin()
                let authorizationCode = response.authorizationCode ?? ""
                keychainManager.save(
                    authorizationCode,
                    key: .appleAuthorizationCode
                )
                return response.toModel()
            },
            appleToken: {
                let code = keychainManager.read(.appleAuthorizationCode) ?? ""
                let request = AppleTokenRequest(
                    clientSecret: manager.makeJWT(),
                    code: code
                )
                dump(request)
                let response: AppleTokenResponse = try await requestNonKey(
                    .appleToken(request)
                )
                keychainManager.save(
                    response.refreshToken,
                    key: .appleRefreshToken
                )
            },
            appleRevoke: {
                let token = keychainManager.read(.appleRefreshToken) ?? ""
                let request = AppleRevokeRequest(
                    clientSecret: manager.makeJWT(),
                    token: token
                )
                try await requestNonKey(.appleRevoke(request))
            },
            withdrawKakao: { manager.withdrawKakaoLogin() }
        )
    }()
    
    static let testValue: SocialLoginClient = {
        return SocialLoginClient(
            kakaoLogin: { SocialLoginResponse.mock.toModel() },
            appleLogin: { SocialLoginResponse.mock.toModel() },
            appleToken: { },
            appleRevoke: { },
            withdrawKakao: { }
        )
    }()
}

extension EnvironmentValues {
    var socialLoginClient: SocialLoginClient {
        get { self[SocialLoginClient.self] }
        set { self[SocialLoginClient.self] = newValue }
    }
}
