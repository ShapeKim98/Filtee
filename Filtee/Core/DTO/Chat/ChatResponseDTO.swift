//
//  ChatResponseDTO.swift
//  Filtee
//
//  Created by 김도형 on 7/7/25.
//

import Foundation

struct ChatResponseDTO: ResponseDTO {
    let chatId: String
    let roomId: String
    let content: String
    let createdAt: String
    let updatedAt: String
    let sender: UserInfoResponseDTO
    let files: [String]
    
    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case roomId = "room_id"
        case content
        case createdAt
        case updatedAt
        case sender
        case files
    }
}

extension ChatResponseDTO {
    func toModel() -> ChatModel {
        return ChatModel(
            id: self.chatId,
            roomId: self.roomId,
            content: self.content,
            createdAt: self.createdAt.toDate(.chat) ?? .now,
            updatedAt: self.updatedAt.toDate(.chat) ?? .now,
            sender: self.sender.toModel()
        )
    }
}
