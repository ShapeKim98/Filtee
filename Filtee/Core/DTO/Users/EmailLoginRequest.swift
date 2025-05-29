//
//  LoginRequest.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import Foundation

struct EmailLoginRequest: RequestDTO {
    let email: String
    let password: String
    let deviceToken: String?
}
