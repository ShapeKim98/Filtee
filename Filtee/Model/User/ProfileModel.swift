//
//  ProfileModel.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

struct ProfileModel: Identifiable, Hashable {
    let id: String
    let email: String?
    let nick: String
    let name: String?
    var introduction: String?
    var description: String?
    let profileImage: String?
    let phoneNum: String?
    let hashTags: [String]
}

extension UserInfoResponseDTO {
    func toModel() -> ProfileModel {
        return ProfileModel(
            id: self.userId,
            email: self.email,
            nick: self.nick,
            name: self.name,
            introduction: self.introduction,
            description: self.description,
            profileImage: self.profileImage?.imageURL,
            phoneNum: self.phoneNum,
            hashTags: self.hashTags
        )
    }
}
