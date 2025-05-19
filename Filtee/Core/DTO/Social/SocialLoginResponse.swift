//
//  SocialLoginResponse.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import Foundation

struct SocialLoginResponse: Sendable {
    let token: String
    let nick: String?
    let authorizationCode: String?
    
    init(
        token: String,
        nick: String? = nil,
        authorizationCode: String? = nil
    ) {
        self.token = token
        self.nick = nick
        self.authorizationCode = authorizationCode
    }
}

extension SocialLoginResponse {
    static let mock = SocialLoginResponse(token: "")
}
