//
//  KakaoLoginRequest.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import Foundation

struct KakaoLoginRequest: RequestDTO {
    let oauthToken: String
    let deviceToken: String?
}
