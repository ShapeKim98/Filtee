//
//  OrderEndpoint.swift
//  Filtee
//
//  Created by 김도형 on 6/16/25.
//

import Foundation

import Alamofire

enum OrderEndpoint: Endpoint {
    case ordersCreate(OrderCreateRequest)
    
    var path: String {
        switch self {
        case .ordersCreate:
            return "/v1/orders"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .ordersCreate:
            return .post
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
        case .ordersCreate:
            return .json
        }
    }
    
    var parameters: (any RequestDTO)? {
        switch self {
        case let .ordersCreate(model):
            return model
        }
    }
    
}
