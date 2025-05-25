//
//  FilterEndpoint.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

import Alamofire

enum FilterEndpoint: Endpoint {
    case hotTrend
    case todayFilter
    
    var path: String {
        switch self {
        case .hotTrend:
            return "/v1/filters/hot-trend"
        case .todayFilter:
            return "/v1/filters/today-filter"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .hotTrend,
             .todayFilter:
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
        case .hotTrend,
             .todayFilter:
            return nil
        }
    }
    
    var parameters: (any RequestData)? {
        switch self {
        case .hotTrend,
             .todayFilter:
            return nil
        }
    }
}
