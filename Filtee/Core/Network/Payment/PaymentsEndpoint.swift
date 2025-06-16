//
//  PaymentsEndpoint.swift
//  Filtee
//
//  Created by 김도형 on 6/16/25.
//

import Foundation

import Alamofire

enum PaymentsEndpoint: Endpoint {
    case paymentsValidation(impUid: String)
    
    var path: String {
        switch self {
        case .paymentsValidation:
            return "/v1/payments/validation"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .paymentsValidation:
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
        case .paymentsValidation:
            return .json
        }
    }
    
    var parameters: (any RequestDTO)? {
        switch self {
        case let .paymentsValidation(impUid):
            return ["imp_uid": impUid]
        }
    }
}
