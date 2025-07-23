//
//  BannerEndpoint.swift
//  Filtee
//
//  Created by 김도형 on 7/23/25.
//

import Foundation

import Alamofire

enum BannerEndpoint: Endpoint {
    case bannersMain
    
    var path: String {
        switch self {
        case .bannersMain:
            return "/v1/banners/main"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .bannersMain: return .get
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
        case .bannersMain: return nil
        }
    }
    
    var parameters: (any RequestDTO)? {
        switch self {
        case .bannersMain: return nil
        }
    }
}
