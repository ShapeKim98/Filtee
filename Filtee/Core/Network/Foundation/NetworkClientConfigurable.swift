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
    
    static func request<T: ResponseData>(_ endPoint: E) async throws -> T
    static func request(_ endPoint: E) async throws
    static func requestNonToken<T: ResponseData>(
        _ endPoint: E,
        adaptable: Bool
    ) async throws -> T
    static func requestNonToken(
        _ endPoint: E,
        adaptable: Bool
    ) async throws
}

extension NetworkClientConfigurable {
    static func request<T: ResponseData>(_ endPoint: E) async throws -> T {
        let session = AF.request(
            endPoint,
            interceptor: Interceptor(
                adapters: [KeyAdapter()],
                interceptors: [TokenInterceptor()]
            )
        )
#if DEBUG
        try? NetworkLogger.request(session.convertible)
#endif
        let response = await session
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
            guard let data = response.data else {
                throw error
            }
            throw try endPoint.errorBody(data: data)
        }
    }
    
    static func request(_ endPoint: E) async throws {
        let session = AF.request(
            endPoint,
            interceptor: Interceptor(
                adapters: [KeyAdapter()],
                interceptors: [TokenInterceptor()]
            )
        )
#if DEBUG
        try? NetworkLogger.request(session.convertible)
#endif
        let response = await session
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
            guard let data = response.data else {
                throw error
            }
            throw try endPoint.errorBody(data: data)
        }
    }
    
    static func requestNonToken<T: ResponseData>(
        _ endPoint: E,
        adaptable: Bool = true
    ) async throws -> T {
        let session = AF.request(
            endPoint,
            interceptor: Interceptor(adapters: adaptable ? [KeyAdapter()] : [])
        )
#if DEBUG
        try? NetworkLogger.request(session.convertible)
#endif
        let response = await session
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
            guard let data = response.data else {
                throw error
            }
            throw try endPoint.errorBody(data: data)
        }
    }
    
    static func requestNonToken(
        _ endPoint: E,
        adaptable: Bool = true
    ) async throws {
        let session = AF.request(
            endPoint,
            interceptor: Interceptor(adapters: adaptable ? [KeyAdapter()] : [])
        )
#if DEBUG
        try? NetworkLogger.request(session.convertible)
#endif
        let response = await session
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
            guard let data = response.data else {
                throw error
            }
            throw try endPoint.errorBody(data: data)
        }
    }
}
