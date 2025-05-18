//
//  Endpoint.swift
//  Filtee
//
//  Created by 김도형 on 5/16/25.
//

import Foundation

import Alamofire

protocol Endpoint: URLRequestConvertible {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders { get }
    var decoder: JSONDecoder { get }
    var encoder: ParameterEncoder? { get }
    var parameters: (Encodable & Sendable)? { get }
//    func error(_ statusCode: Int?, data: Data) -> Error
}

extension Endpoint {
    var baseURL: String {
        return Bundle.main.baseURL
    }
    
    func asURLRequest() throws -> URLRequest {
        var request = try URLRequest(
            url: baseURL + path,
            method: method,
            headers: headers
        )
        if let encoder, let parameters {
            request = try encoder.encode(parameters, into: request)
        }
        return request
    }
    
//    func error(_ statusCode: Int?, data: Data) -> Error {
//        return
//    }
}

enum FilteeError: Error {
    case tokenNotFound
    case reissueFail
}
