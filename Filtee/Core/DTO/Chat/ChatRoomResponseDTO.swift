//
//  ChatRoomResponseDTO.swift
//  Filtee
//
//  Created by 김도형 on 7/7/25.
//

import Foundation

struct ChatRoomResponseDTO: Decodable {
    let roomId: String
    let createdAt: String
    let updatedAt: String
    let participants: [UserInfoResponseDTO]
    let lastChat: ChatResponseDTO?
    
    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case createdAt
        case updatedAt
        case participants
        case lastChat
    }
}

extension ChatRoomResponseDTO {
    func toModel() -> RoomModel {
        return RoomModel(
            id: self.roomId,
            createdAt: self.createdAt.toDate(.chat) ?? .now,
            updatedAt: self.updatedAt.toDate(.chat) ?? .now,
            participants: self.participants.map { $0.toUserInfoModel() },
            lastChat: self.lastChat?.toModel()
        )
    }
}
