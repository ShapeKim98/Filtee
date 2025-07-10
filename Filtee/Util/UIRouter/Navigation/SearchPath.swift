//
//  SearchPath.swift
//  Filtee
//
//  Created by 김도형 on 7/10/25.
//

import Foundation

enum SearchPath: Hashable, Sendable {
    case chat(opponentId: String)
    case userDetail(user: ProfileModel)
}
