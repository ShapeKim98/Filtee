//
//  AppleTokenResponse.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import Foundation

struct AppleTokenResponse: Decodable {
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}
