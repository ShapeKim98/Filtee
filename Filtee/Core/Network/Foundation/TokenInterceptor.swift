//
//  TokenInterceptor.swift
//  Filtee
//
//  Created by 김도형 on 5/16/25.
//

import Foundation

import Alamofire

struct TokenInterceptor: RequestInterceptor, NetworkClientConfigurable {
    typealias E = AuthEndpoint
    
    private let keychainManager = KeychainManager.shared
    
    nonisolated func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping @Sendable (Result<URLRequest, Error>) -> Void
    ) {
        var request = urlRequest
        guard let accessToken = keychainManager.read(.accessToken) else {
            completion(.failure(FilteeError.tokenNotFound))
            return
        }
        request.addValue(
            "\(accessToken)",
            forHTTPHeaderField: "Authorization"
        )
        completion(.success(request))
    }
    
    nonisolated func retry(
        _ request: Request,
        for session: Session,
        dueTo error: any Error,
        completion: @escaping @Sendable (RetryResult) -> Void
    ) {
        if case let AFError.requestAdaptationFailed(adaptationError) = error {
            completion(.doNotRetryWithError(adaptationError))
            return
        }
        if case let AFError.requestRetryFailed(
            retryError: retryError,
            originalError: _
        ) = error {
            completion(.doNotRetryWithError(retryError))
            return
        }
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetryWithError(error))
            return
        }
        guard response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        guard let refreshToken = keychainManager.read(.refreshToken) else {
            completion(.doNotRetryWithError(FilteeError.tokenNotFound))
            return
        }
        
        Task {
            do {
                guard let response: TokenResponse = try await Self.request(.refresh(refreshToken)) else {
                    completion(.doNotRetryWithError(FilteeError.reissueFail))
                    return
                }
                keychainManager.save(
                    response.accessToken,
                    key: .accessToken
                )
                keychainManager.save(
                    response.refreshToken,
                    key: .refreshToken
                )
                completion(.retry)
            } catch {
                completion(.doNotRetryWithError(FilteeError.reissueFail))
            }
        }
    }
}
