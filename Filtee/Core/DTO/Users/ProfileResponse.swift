//
//  ProfileResponse.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

struct ProfileResponse: ResponseData {
    let userId: String
    let email: String?
    let nick: String
    let name: String?
    let introduction: String?
    let profileImage: String?
    let phoneNum: String?
    let hashTags: [String]
}
