//
//  AppleLoginRequest.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import Foundation

struct AppleLoginRequest: RequestDTO {
    let idToken: String
    let deviceToken: String?
    let nick: String?
}
