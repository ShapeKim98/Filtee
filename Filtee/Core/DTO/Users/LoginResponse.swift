//
//  LoginResponse.swift
//  Filtee
//
//  Created by 김도형 on 5/20/25.
//

import Foundation

struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}

