//
//  TokenResponse.swift
//  Filtee
//
//  Created by 김도형 on 5/16/25.
//

import Foundation

struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
