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
    let lastChat: ChatResponseDTO
}

extension ChatRoomResponseDTO {
    func toModel() -> RoomModel {
        return RoomModel(
            id: self.roomId,
            createdAt: self.createdAt.toDate(.default) ?? .now,
            updatedAt: self.updatedAt.toDate(.default) ?? .now,
            participants: self.participants.map { $0.toModel() }
        )
    }
}
