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
    case filterDetail(id: String)
    case filterLike(id: String, isLike: Bool)
    case files([MultipartForm])
    case filters(FilterMakeRequest)
    case users(
        userId: String,
        next: String?,
        limit: Int,
        category: String?
    )
    
    var path: String {
        switch self {
        case .hotTrend:
            return "/v1/filters/hot-trend"
        case .todayFilter:
            return "/v1/filters/today-filter"
        case let .filterDetail(id):
            return "/v1/filters/\(id)"
        case let .filterLike(id, _):
            return "/v1/filters/\(id)/like"
        case .files:
            return "/v1/filters/files"
        case .filters:
            return "/v1/filters"
        case let .users(userId, _, _, _):
            return "/v1/filters/users/\(userId)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .hotTrend,
             .todayFilter,
             .filterDetail,
             .users:
            return .get
        case .filterLike,
             .files,
             .filters:
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
        case .hotTrend,
             .todayFilter,
             .filterDetail,
             .files:
            return nil
        case .filterLike,
             .filters:
            return .json
        case .users:
            return .urlEncodedForm
        }
    }
    
    var parameters: (any RequestDTO)? {
        switch self {
        case .hotTrend,
             .todayFilter,
             .filterDetail,
             .files:
            return nil
        case let .filterLike(_, isLike):
            return ["like_status": isLike]
        case let .filters(model):
            return model
        case let .users(_, next, limit, category):
            var parameters = ["limit": "\(limit)"]
            if let next {
                parameters.updateValue(next, forKey: "next")
            }
            if let category {
                parameters.updateValue(category, forKey: "category")
            }
            return parameters
        }
    }
    
    var multipartForm: [MultipartForm] {
        switch self {
        case let .files(files):
            return files
        default: return []
        }
    }
}
