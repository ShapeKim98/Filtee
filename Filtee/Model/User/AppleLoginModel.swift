//
//  AppleLoginModel.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import Foundation

struct AppleLoginModel {
    let idToken: String
    let deviceToken: String?
    let nick: String?
    
    init(idToken: String, deviceToken: String? = nil, nick: String? = nil) {
        self.idToken = idToken
        self.deviceToken = deviceToken
        self.nick = nick
    }
}

extension AppleLoginModel {
    func toData() -> AppleLoginRequest {
        return AppleLoginRequest(
            idToken: self.idToken,
            deviceToken: self.deviceToken,
            nick: self.nick
        )
    }
}
