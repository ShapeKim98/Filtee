//
//  MyInfoResponseDTO.swift
//  Filtee
//
//  Created by 김도형 on 6/17/25.
//

import Foundation

struct MyInfoResponseDTO: ResponseDTO {
    let userId: String
    let email: String
    let nick: String
    let name: String?
    let introduction: String?
    let profileImage: String?
    let phoneNum: String?
    let hashTags: [String]
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case nick
        case name
        case introduction
        case profileImage
        case phoneNum
        case hashTags
    }
}
