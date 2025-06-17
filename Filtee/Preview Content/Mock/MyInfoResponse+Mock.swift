//
//  MyInfoResponse+Mock.swift
//  Filtee
//
//  Created by 김도형 on 6/17/25.
//

import Foundation

extension MyInfoResponseDTO {
    static let mock = MyInfoResponseDTO(
        userId: "6816ee1c6d1bff703149336f",
        email: "sesac@sesac.com",
        nick: "sesac",
        name: "김새싹",
        introduction: "프로필 소개입니다.",
        profileImage: "/data/profiles/1712739634962.png",
        phoneNum: "010-1234-1234",
        hashTags: ["#맑음"]
    )
}
