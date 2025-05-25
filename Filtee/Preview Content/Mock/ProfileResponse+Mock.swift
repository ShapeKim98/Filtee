//
//  ProfileResponse+Mock.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

extension ProfileResponse {
    static let todayAuthorMock = ProfileResponse(
        userId: "6816ee1c6d1bff703149336f",
        email: nil,
        nick: "SESAC YOON",
        name: "윤새싹",
        introduction: "자연의 섬세함을 담아내는 감성 사진작가",
        description: "윤새싹은 자연의 섬세한 아름다움을 포착하는 데 탁월한 감각을 지닌 사진작...",
        profileImage: "/data/profiles/1712739634962.png",
        phoneNum: nil,
        hashTags: ["#섬세함"]
    )
    
    static let creatorMock = ProfileResponse(
        userId: "6816ee1c6d1bff703149336f",
        email: nil,
        nick: "sesac",
        name: "김새싹",
        introduction: "프로필 소개입니다.",
        description: nil,
        profileImage: "/data/profiles/1712739634962.png",
        phoneNum: nil,
        hashTags: ["#맑음"]
    )
}
