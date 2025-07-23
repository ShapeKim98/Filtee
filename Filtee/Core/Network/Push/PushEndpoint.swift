//
//  PushEndpoint.swift
//  Filtee
//
//  Created by 김도형 on 7/23/25.
//

import Foundation

import Alamofire

enum PushEndpoint: Endpoint {
    case notificationsPushGroup(PushRequest)
    
    var path: String {
        switch self {
        case .notificationsPushGroup:
            return "/v1/notifications/push/group"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .notificationsPushGroup: return .post
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
        case .notificationsPushGroup: return .json
        }
    }
    
    var parameters: (any RequestDTO)? {
        switch self {
        case let .notificationsPushGroup(model):
            return model
        }
    }
}
