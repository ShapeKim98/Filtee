//
//  UserClient+TestValue.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

extension UserClient {
    static let testValue: UserClient = {
        return UserClient(
            validationEmail: { _ in },
            join: { _ in },
            emailLogin: { _ in },
            kakaoLogin: { _ in },
            appleLogin: { _ in },
            deviceToken: { _ in },
            logout: { },
            todayAuthor: {
                TodayAuthorResponseDTO.mock.toModel()
            }
        )
    }()
}
