//
//  AuthEndpoint.swift
//  Filtee
//
//  Created by 김도형 on 5/16/25.
//

import Foundation

import Alamofire

enum AuthEndpoint: Endpoint {
    case refresh(String)
    
    var path: String {
        switch self {
        case .refresh: return "/v1/auth/refresh"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .refresh: return .get
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case let .refresh(refreshToken):
            ["RefreshToken": refreshToken]
        }
    }
    
    var decoder: JSONDecoder {
        JSONDecoder()
    }
    
    var encoder: (any ParameterEncoder)? {
        switch self {
        case .refresh: return nil
        }
    }
    
    var parameters: (any RequestDTO)? {
        switch self {
        case .refresh: return nil
        }
    }
}
