//
//  SearchPath.swift
//  Filtee
//
//  Created by 김도형 on 7/10/25.
//

import Foundation

enum SearchPath: Hashable, Sendable {
    case userDetail(userId: String)
    case chat(opponentId: String)
}
