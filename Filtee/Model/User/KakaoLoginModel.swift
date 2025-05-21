//
//  KakaoLoginModel.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import Foundation

struct KakaoLoginModel {
    let oauthToken: String
    let deviceToken: String?
    
    init(oauthToken: String, deviceToken: String? = nil) {
        self.oauthToken = oauthToken
        self.deviceToken = deviceToken
    }
}

extension KakaoLoginModel {
    func toData() -> KakaoLoginRequest {
        return KakaoLoginRequest(
            oauthToken: self.oauthToken,
            deviceToken: self.deviceToken
        )
    }
}
