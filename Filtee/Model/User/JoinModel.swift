//
//  JoinModel.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import Foundation

struct JoinModel {
    let email: String
    let password: String
    let nick: String
    let name: String?
    let introduction: String?
    let phoneNum: String?
    let hashTags: [String]?
    let deviceToken: String?
    
    init(
        email: String = "",
        password: String = "",
        nick: String = "",
        name: String? = nil,
        introduction: String? = nil,
        phoneNum: String? = nil,
        hashTags: [String]? = nil,
        deviceToken: String? = nil
    ) {
        self.email = email
        self.password = password
        self.nick = nick
        self.name = name
        self.introduction = introduction
        self.phoneNum = phoneNum
        self.hashTags = hashTags
        self.deviceToken = deviceToken
    }
}

extension JoinModel {
    func toData() -> JoinRequest {
        return JoinRequest(
            email: self.email,
            password: self.password,
            nick: self.nick,
            name: self.name,
            introduction: self.introduction,
            phoneNum: self.phoneNum,
            hashTags: self.hashTags,
            deviceToken: self.deviceToken
        )
    }
}
