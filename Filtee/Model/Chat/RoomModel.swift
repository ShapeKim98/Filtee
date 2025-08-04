//
//  RoomModel.swift
//  Filtee
//
//  Created by 김도형 on 7/7/25.
//

import Foundation

struct RoomModel {
    let id: String
    let createdAt: Date
    let updatedAt: Date
    let participants: [UserInfoModel]
    let lastChat: ChatModel?
}
