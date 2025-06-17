//
//  MyInfoModel.swift
//  Filtee
//
//  Created by 김도형 on 6/17/25.
//

import Foundation

struct MyInfoModel {
    let userId: String
    let email: String
    let nick: String
    let name: String?
    let introduction: String?
    let profileImage: String?
    let phoneNum: String?
    let hashTags: [String]
}

extension MyInfoResponseDTO {
    func toModel() -> MyInfoModel {
        return MyInfoModel(
            userId: self.userId,
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
