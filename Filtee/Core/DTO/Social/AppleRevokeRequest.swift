//
//  AppleRevokeRequest.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import Foundation

struct AppleRevokeRequest: Encodable, Sendable {
    let clientId: String
    let clientSecret: String
    let token: String
    let tokenTypeHint: String
    
    init(
        clientId: String = "com.dohyeong.ShowPot",
        clientSecret: String,
        token: String,
        tokenTypeHint: String = "refresh_token"
    ) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.token = token
        self.tokenTypeHint = tokenTypeHint
    }
    
    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case token
        case tokenTypeHint = "token_type_hint"
    }
}
