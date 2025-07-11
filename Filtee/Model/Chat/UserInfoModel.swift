//
//  UserInfoModel.swift
//  Filtee
//
//  Created by 김도형 on 7/7/25.
//

import Foundation

struct UserInfoModel: Identifiable {
    let id: String
    let nick: String
    let profileImage: String?
    let name: String?
    let hashTags: [String]
}
