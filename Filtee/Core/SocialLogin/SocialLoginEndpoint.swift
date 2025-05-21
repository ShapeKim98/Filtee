//
//  SocialLoginEndpoint.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import Foundation

import Alamofire

enum SocialLoginEndpoint: Endpoint {
    case appleToken(AppleTokenRequest)
    case appleRevoke(AppleRevokeRequest)
    
    var baseURL: String {
        return "https://appleid.apple.com"
    }
    
    var path: String {
        switch self {
        case .appleToken:
            return "/auth/token"
        case .appleRevoke:
            return "/auth/revoke"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .appleToken,
             .appleRevoke:
            return .post
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .appleToken,
             .appleRevoke:
            return ["Content-Type": "application/x-www-form-urlencoded"]
        }
    }
    
    var decoder: JSONDecoder {
        return JSONDecoder()
    }
    
    var encoder: (any ParameterEncoder)? {
        switch self {
        case .appleToken,
             .appleRevoke:
            return .urlEncodedForm
        }
    }
    
    var parameters: (any RequestData)? {
        switch self {
        case let .appleToken(model):
            return model
        case let .appleRevoke(model):
            return model
        }
    }
}
