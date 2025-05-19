//
//  LoginModel.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import Foundation

struct EmailLoginModel {
    let email: String
    let password: String
    let deviceToken: String?
    
    init(email: String, password: String, deviceToken: String? = nil) {
        self.email = email
        self.password = password
        self.deviceToken = deviceToken
    }
}

extension EmailLoginModel {
    func toData() -> EmailLoginRequest {
        return EmailLoginRequest(
            email: self.email,
            password: self.password,
            deviceToken: self.deviceToken
        )
    }
}
