//
//  AuthClient.swift
//  Filtee
//
//  Created by 김도형 on 5/18/25.
//

import SwiftUICore

struct AuthClient: Sendable {
    var refresh: @Sendable () async throws -> Void
}

extension AuthClient: EnvironmentKey, NetworkClientConfigurable {
    typealias E = AuthEndpoint
    
    static let defaultValue: AuthClient = {
        return AuthClient(
            refresh: {
                let keychainManager = KeychainManager.shared
                let refreshToken = await keychainManager.read(.refreshToken)
                guard let refreshToken else { throw FilteeError.tokenNotFound }
                
                do {
                    let response: TokenResponse = try await requestNonToken(
                        .refresh(refreshToken)
                    )
                    await keychainManager.save(
                        response.accessToken,
                        key: .accessToken
                    )
                    await keychainManager.save(
                        response.refreshToken,
                        key: .refreshToken
                    )
                } catch {
                    await keychainManager.delete(.accessToken)
                    await keychainManager.delete(.refreshToken)
                    throw FilteeError.reissueFail
                }
            }
        )
    }()
    
    static let testValue: AuthClient = {
        return AuthClient(
            refresh: { }
        )
    }()
}

extension EnvironmentValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
