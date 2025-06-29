//
//  ProfileResponse.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

struct UserInfoResponseDTO: ResponseDTO {
    let userId: String
    let email: String?
    let nick: String
    let name: String?
    let introduction: String?
    let description: String?
    let profileImage: String?
    let phoneNum: String?
    let hashTags: [String]
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case nick
        case name
        case introduction
        case description
        case profileImage
        case phoneNum
        case hashTags
    }
}
