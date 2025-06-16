//
//  LoginResponse.swift
//  Filtee
//
//  Created by 김도형 on 5/20/25.
//

import Foundation

struct LoginDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}

