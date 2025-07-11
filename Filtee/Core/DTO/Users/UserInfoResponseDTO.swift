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

extension UserInfoResponseDTO {
    func toUserInfoModel() -> UserInfoModel {
        return UserInfoModel(
            id: self.userId,
            nick: self.nick,
            profileImage: self.profileImage,
            name: self.name,
            hashTags: self.hashTags
        )
    }
    
    func toProfileModel() -> ProfileModel {
        return ProfileModel(
            id: self.userId,
            email: self.email,
            nick: self.nick,
            name: self.nick,
            introduction: self.introduction,
            description: self.description,
            profileImage: self.profileImage,
            phoneNum: self.phoneNum,
            hashTags: self.hashTags
        )
    }
}
