//
//  ChatEndpoint.swift
//  Filtee
//
//  Created by 김도형 on 7/7/25.
//

import Foundation

import Alamofire

enum ChatEndpoint: Endpoint {
    case webSocket(String)
    case createChats(String)
    case chats(ChatsReqeust)
    case sendChats(SendChatsRequest)
    
    var path: String {
        switch self {
        case let .webSocket(roomId):
            return "/chats-\(roomId)"
        case .createChats:
            return "/v1/chats"
        case let .chats(model):
            return "/v1/chats/\(model.roomId)"
        case let .sendChats(model):
            return "/v1/chats/\(model.roomId)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .webSocket: return .connect
        case .createChats: return .post
        case .chats: return .get
        case .sendChats: return .post
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
        case .webSocket: return nil
        case .createChats: return .json
        case .chats: return .urlEncodedForm
        case .sendChats: return .json
        }
    }
    
    var parameters: (any RequestDTO)? {
        switch self {
        case .webSocket: return nil
        case let .createChats(id):
            return ["opponent_id": id]
        case let .chats(model):
            return ["next": model.next]
        case let .sendChats(model):
            return ["content": model.content]
        }
    }
    
}
