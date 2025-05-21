//
//  ProfileModel.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

struct ProfileModel: Identifiable {
    let id: String
    let email: String?
    let nick: String
    let name: String?
    let introduction: String?
    let profileImage: String?
    let phoneNum: String?
    let hashTags: [String]
}

extension ProfileResponse {
    func toModel() -> ProfileModel {
        return ProfileModel(
            id: self.userId,
            email: self.email,
            nick: self.nick,
            name: self.name,
            introduction: self.introduction,
            profileImage: self.profileImage?.imageURL,
            phoneNum: self.phoneNum,
            hashTags: self.hashTags
        )
    }
}
