//
//  NetworkClientConfigurable.swift
//  Filtee
//
//  Created by 김도형 on 5/16/25.
//

import Foundation

import Alamofire

protocol NetworkClientConfigurable {
    associatedtype E: Endpoint
    
    static func request<T: Decodable & Sendable>(_ endPoint: E) async throws -> T
    static func request(_ endPoint: E) async throws
    static func requestNonToken<T: Decodable & Sendable>(_ endPoint: E) async throws -> T
    static func requestNonToken(_ endPoint: E) async throws
}

extension NetworkClientConfigurable {
    static func request<T: Decodable & Sendable>(_ endPoint: E) async throws -> T {
#if DEBUG
        try? NetworkLogger.request(endPoint)
#endif
        let response = await AF.request(
            endPoint,
            interceptor: Interceptor(
                adapter: KeyAdapter(),
                retrier: TokenInterceptor.shared
            )
        )
        .validate(statusCode: 200..<300)
        .serializingDecodable(T.self, decoder: endPoint.decoder)
        .response
#if DEBUG
        try? NetworkLogger.response(response)
#endif
        switch response.result {
        case .success(let value):
            return value
        case .failure(let error):
            if case let AFError.requestRetryFailed(
                retryError: retryError,
                originalError: _
            ) = error {
                throw retryError
            }
            throw error
        }
    }
    
    static func request(_ endPoint: E) async throws {
#if DEBUG
        try? NetworkLogger.request(endPoint)
#endif
        let response = await AF.request(
            endPoint,
            interceptor: Interceptor(
                adapter: KeyAdapter(),
                retrier: TokenInterceptor.shared
            )
        )
        .validate(statusCode: 200..<300)
        .serializingData()
        .response
#if DEBUG
        try NetworkLogger.response(response)
#endif
        switch response.result {
        case .success: return
        case .failure(let error):
            if case let AFError.requestRetryFailed(
                retryError: retryError,
                originalError: _
            ) = error {
                throw retryError
            }
            if case .responseSerializationFailed(.inputDataNilOrZeroLength) = error,
               response.response?.statusCode == 200 {
                // 빈 응답을 성공으로 처리
                return
            }
            throw error
        }
    }
    
    static func requestNonToken<T: Decodable & Sendable>(_ endPoint: E) async throws -> T {
#if DEBUG
        try? NetworkLogger.request(endPoint)
#endif
        let response = await AF.request(
            endPoint,
            interceptor: Interceptor(adapters: [KeyAdapter()])
        )
        .validate(statusCode: 200..<300)
        .serializingDecodable(T.self, decoder: endPoint.decoder)
        .response
#if DEBUG
        try NetworkLogger.response(response)
#endif
        switch response.result {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
    
    static func requestNonToken(_ endPoint: E) async throws {
#if DEBUG
        try? NetworkLogger.request(endPoint)
#endif
        let response = await AF.request(
            endPoint,
            interceptor: Interceptor(adapters: [KeyAdapter()])
        )
        .validate(statusCode: 200..<300)
        .serializingData()
        .response
#if DEBUG
        try? NetworkLogger.response(response)
#endif
        switch response.result {
        case .success: return
        case .failure(let error):
            if case .responseSerializationFailed(.inputDataNilOrZeroLength) = error,
               response.response?.statusCode == 200 {
                // 빈 응답을 성공으로 처리
                return
            }
            throw error
        }
    }
}
