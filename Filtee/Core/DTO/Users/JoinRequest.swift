//
//  JoinReqeust.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import Foundation

struct JoinRequest: RequestData {
    let email: String
    let password: String
    let nick: String
    let name: String?
    let introduction: String?
    let phoneNum: String?
    let hashTags: [String]?
    let deviceToken: String?
}
