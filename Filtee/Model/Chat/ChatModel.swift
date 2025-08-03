//
//  ChatModel.swift
//  Filtee
//
//  Created by 김도형 on 7/7/25.
//

import Foundation

import IdentifiedCollections

struct ChatModel: Identifiable {
    let id: String
    let roomId: String
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let sender: UserInfoModel?
    let isHead: Bool
    var isTail: Bool
    var files: IdentifiedArrayOf<FileModel>
}
