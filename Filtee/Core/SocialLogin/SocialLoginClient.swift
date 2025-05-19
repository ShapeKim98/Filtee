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
                let response: SocialLoginResponse = try await manager.appleLogin()
                let authorizationCode = response.authorizationCode ?? ""
                await keychainManager.save(
                    authorizationCode,
                    key: .appleAuthorizationCode
                )
                return response.toModel()
            },
            appleToken: {
                let code = await keychainManager.read(.appleAuthorizationCode) ?? ""
                let request = AppleTokenRequest(
                    clientSecret: manager.makeJWT(),
                    code: code
                )
                let response: AppleTokenResponse = try await requestNonToken(.appleToken(request))
                await keychainManager.save(
                    response.refreshToken,
                    key: .appleRefreshToken
                )
            },
            appleRevoke: {
                let token = await keychainManager.read(.appleRefreshToken) ?? ""
                let request = AppleRevokeRequest(
                    clientSecret: manager.makeJWT(),
                    token: token
                )
                try await requestNonToken(.appleRevoke(request))
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
