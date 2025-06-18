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
    
    static func request<T: ResponseDTO>(_ endPoint: E) async throws -> T
    static func request(_ endPoint: E) async throws
    static func requestNonToken<T: ResponseDTO>(_ endPoint: E) async throws -> T
    static func requestNonToken(_ endPoint: E) async throws
    static func cachedRequest<T: ResponseDTO>(_ endPoint: E) async throws -> T
    static func requestNonKey<T: ResponseDTO>(_ endPoint: E) async throws -> T
    static func requestNonKey(_ endPoint: E) async throws
}

extension NetworkClientConfigurable {
    static func request<T: ResponseDTO>(_ endPoint: E) async throws -> T {
        let response = await defaultSession.request(endPoint)
            .validate(statusCode: 200..<300)
            .serializingDecodable(T.self, decoder: endPoint.decoder)
            .response
        
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
        let response = await defaultSession.request(endPoint)
            .validate(statusCode: 200..<300)
            .serializingData()
            .response
        
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
    
    static func cachedRequest<T: ResponseDTO>(_ endPoint: E) async throws -> T {
        let response = await cachedSession.request(endPoint)
            .validate(statusCode: 200..<300)
            .serializingDecodable(T.self, decoder: endPoint.decoder)
            .response
        
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
    
    static func upload<T: ResponseDTO>(_ endPoint: E) async throws -> T {
        let response = await defaultSession.upload(
            multipartFormData: { multipartFormData in
                for multipartForm in endPoint.multipartForm {
                    multipartFormData.append(
                        multipartForm.data,
                        withName: multipartForm.withName,
                        fileName: multipartForm.fileName,
                        mimeType: multipartForm.mimeType
                    )
                }
            },
            with: endPoint
        )
            .validate(statusCode: 200..<300)
            .serializingDecodable(T.self, decoder: endPoint.decoder)
            .response
        
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
    
    static func requestNonToken<T: ResponseDTO>(_ endPoint: E) async throws -> T {
        let response = await nonTokenSession.request(endPoint)
            .validate(statusCode: 200..<300)
            .serializingDecodable(T.self, decoder: endPoint.decoder)
            .response
        
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
    
    static func requestNonToken(_ endPoint: E) async throws {
        let response = await nonTokenSession.request(endPoint)
            .validate(statusCode: 200..<300)
            .serializingData()
            .response
        
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
    
    static func requestNonKey<T: ResponseDTO>(_ endPoint: E) async throws -> T {
        let response = await AF.request(endPoint)
            .validate(statusCode: 200..<300)
            .serializingDecodable(T.self, decoder: endPoint.decoder)
            .response
        
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
    
    static func requestNonKey(_ endPoint: E) async throws {
        let response = await AF.request(endPoint)
            .validate(statusCode: 200..<300)
            .serializingData()
            .response
        
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
