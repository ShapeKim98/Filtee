//
//  SocialLoginModel.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import Foundation

struct SocialLoginModel {
    let token: String
    let nick: String?
    let authorizationCode: String?
    
    init(
        token: String,
        nick: String?,
        authorizationCode: String?
    ) {
        self.token = token
        self.nick = nick
        self.authorizationCode = authorizationCode
    }
}

extension SocialLoginResponse {
    func toModel() -> SocialLoginModel {
        return SocialLoginModel(
            token: self.token,
            nick: self.nick,
            authorizationCode: self.authorizationCode
        )
    }
}
