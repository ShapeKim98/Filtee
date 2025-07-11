//
//  UserEndpoint.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import Foundation

import Alamofire

enum UserEndpoint: Endpoint {
    case validationEmail(email: String)
    case join(JoinRequest)
    case login(EmailLoginRequest)
    case kakoLogin(KakaoLoginRequest)
    case appleLogin(AppleLoginRequest)
    case deviceToken(deviceToken: String)
    case todayAuthor
    case meProfile
    case search(nick: String)
    
    var path: String {
        switch self {
        case .validationEmail:
            return "/v1/users/validation/email"
        case .join:
            return "/v1/users/join"
        case .login:
            return "/v1/users/login"
        case .kakoLogin:
            return "/v1/users/login/kakao"
        case .appleLogin:
            return "/v1/users/login/apple"
        case .deviceToken:
            return "/v1/users/deviceToken"
        case .todayAuthor:
            return "/v1/users/today-author"
        case .meProfile:
            return "/v1/users/me/profile"
        case .search:
            return "/v1/users/search"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .validationEmail,
            .join,
            .login,
            .kakoLogin,
            .appleLogin:
            return .post
        case .deviceToken: return .put
        case .todayAuthor,
             .meProfile,
             .search:
            return .get
        }
    }
    
    var headers: HTTPHeaders {
        return [:]
    }
    
    var decoder: JSONDecoder {
        JSONDecoder()
    }
    
    var encoder: (any ParameterEncoder)? {
        switch self {
        case .validationEmail,
             .join,
             .login,
             .kakoLogin,
             .appleLogin,
             .deviceToken:
            return .json
        case .todayAuthor,
             .meProfile:
            return nil
        case .search:
            return .urlEncodedForm
        }
    }
    
    var parameters: (any RequestDTO)? {
        switch self {
        case let .validationEmail(email):
            return ["email": email]
        case let .join(model):
            return model
        case let .login(model):
            return model
        case let .kakoLogin(model):
            return model
        case let .appleLogin(model):
            return model
        case let .deviceToken(deviceToken):
            return ["deviceToken": deviceToken]
        case .todayAuthor,
             .meProfile:
            return nil
        case let .search(nick):
            return ["nick": nick]
        }
    }
}
