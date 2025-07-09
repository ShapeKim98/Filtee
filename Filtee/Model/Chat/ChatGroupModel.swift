//
//  ChatGroupModel.swift
//  Filtee
//
//  Created by 김도형 on 7/7/25.
//

import Foundation

struct ChatGroupModel: Identifiable {
    let id: String
    let latestedAt: Date
    let chats: [ChatModel]
    let sender: UserInfoModel?
}
