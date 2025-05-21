//
//  AppleTokenReqeust.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import Foundation

struct AppleTokenRequest: RequestData {
    let clientId: String
    let clientSecret: String
    let code: String
    let grantType: String
    
    init(
        clientId: String = "com.dohyeong.Filtee",
        clientSecret: String,
        code: String,
        grantType: String = "authorization_code"
    ) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.code = code
        self.grantType = grantType
    }
    
    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case code
        case grantType = "grant_type"
    }
}
