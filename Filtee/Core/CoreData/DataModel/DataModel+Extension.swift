//
//  DataModel+Extension.swift
//  Filtee
//
//  Created by 김도형 on 7/2/25.
//

import Foundation
import CoreData

extension RoomDataModel: @unchecked Sendable { }

extension RoomDataModel {
    func toModel() -> RoomModel {
        let senderSet = self.participants as? Set<SenderDataModel> ?? []
        let senders = senderSet.sorted { $0.nick ?? "" < $1.nick ?? "" }
        
        return RoomModel(
            id: self.roomId ?? "",
            createdAt: self.createdAt ?? .now,
            updatedAt: self.updatedAt ?? .now,
            participants: senders.map { $0.toModel() }
        )
    }
}

extension ChatGroupDataModel: @unchecked Sendable { }

extension ChatGroupDataModel {
    func toModel() -> ChatGroupModel {
        let chatSet = self.chats as? Set<ChatDataModel> ?? []
        let chats = chatSet.sorted { $0.createdAt ?? .now < $1.createdAt ?? .now }
        
        return ChatGroupModel(
            id: self.objectID.description,
            latestedAt: self.latestedAt ?? .now,
            chats: chats.map { $0.toModel() },
            sender: self.sender?.toModel()
        )
    }
}

extension ChatDataModel: @unchecked Sendable { }

extension ChatDataModel {
    func toModel() -> ChatModel {
        return ChatModel(
            id: self.chatId ?? "",
            roomId: self.roomId ?? "",
            content: self.content ?? "",
            createdAt: self.createdAt ?? .now,
            updatedAt: self.updatedAt ?? .now,
            sender: self.sender?.toModel()
        )
    }
}

extension SenderDataModel: @unchecked Sendable { }

extension SenderDataModel {
    func toModel() -> UserInfoModel {
        return UserInfoModel(
            id: self.userId ?? "",
            nick: self.nick ?? "",
            profileImage: self.profileImage ?? ""
        )
    }
}
