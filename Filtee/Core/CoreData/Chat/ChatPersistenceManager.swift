//
//  ChatClient.swift
//  Filtee
//
//  Created by 김도형 on 6/24/25.
//

import SwiftUICore
import CoreData

final class ChatPersistenceManager {
    private let context = PersistenceProvider.shared.container.newBackgroundContext()
    
    func createChat(
        chatId: String,
        content: String,
        roomObjectId: NSManagedObjectID,
        senderObjectId: NSManagedObjectID,
        filesData: Data? = nil,
        createdAt: Date,
        updatedAt: Date,
        chatGroupObjectId: NSManagedObjectID?
    ) async throws {
        let sender: SenderModel = try await read(senderObjectId)
        var chatGroup: ChatGroupModel? = nil
        if let chatGroupObjectId {
            chatGroup = try await read(chatGroupObjectId)
        }
        let room: RoomModel = try await read(roomObjectId)
        try await _createChat(
            chatId: chatId,
            content: content,
            room: room,
            sender: sender,
            filesData: filesData,
            createdAt: createdAt,
            updatedAt: updatedAt,
            chatGroup: chatGroup
        )
    }
    
    @discardableResult
    func _createChat(
        chatId: String,
        content: String,
        room: RoomModel,
        sender: SenderModel,
        filesData: Data? = nil,
        createdAt: Date,
        updatedAt: Date,
        chatGroup: ChatGroupModel?
    ) async throws -> ChatModel {
        let chat: ChatModel = try await save { context in
            let chat = ChatModel(context: context)
            chat.chatId = chatId
            chat.content = content
            chat.roomId = room.roomId
            chat.sender = sender
            chat.filesData = filesData
            chat.createdAt = createdAt
            chat.updatedAt = updatedAt
            return chat
        }
        let targetGroup: ChatGroupModel
        if let chatGroup {
            targetGroup = chatGroup
        } else {
            targetGroup = try await _createChatGroup(sender: sender, in: room)
        }
        try await _updateChatGroup(chat: chat, in: targetGroup)
        
        return chat
    }
    
    /// 채팅 그룹 업데이트 (latestedAt 갱신)
    @discardableResult
    private func _updateChatGroup(
        chat: ChatModel,
        in chatGroup: ChatGroupModel
    ) async throws -> ChatGroupModel {
        return try await save { context in
            chatGroup.addToChats(chat)
            chatGroup.latestedAt = Date()
            return chatGroup
        }
    }
    
    @discardableResult
    private func _createChatGroup(
        sender: SenderModel,
        in room: RoomModel
    ) async throws -> ChatGroupModel {
        return try await save { context in
            let chatGroup = ChatGroupModel(context: context)
            chatGroup.sender = sender
            chatGroup.latestedAt = Date()
            
            room.addToChats(chatGroup)
            return chatGroup
        }
    }
    
    /// 새 발신자 생성
    @discardableResult
    private func _createSender(
        userId: String,
        nick: String,
        profileImage: String? = nil
    ) async throws -> SenderModel {
        return try await save { context in
            let sender = SenderModel(context: context)
            sender.userId = userId
            sender.nick = nick
            sender.profileImage = profileImage
            return sender
        }
    }
    
    private func save<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        let object = try await context.perform { [weak self] in
            guard let context = self?.context else {
                throw NSError(domain: "Context 가져오기 실패", code: -1)
            }
            let object = try block(context)
            
            guard context.hasChanges else {
                throw NSError(domain: "Context 변경 사항 없음", code: -1)
            }
            
            try context.save()
            
            return object
        }
        
        return object
    }
    
    private func read<T>(_ objectId: NSManagedObjectID) async throws -> T {
        return try await context.perform { [weak self] in
            guard let context = self?.context else {
                throw NSError(domain: "Context 가져오기 실패", code: -1)
            }
            guard let object = context.object(with: objectId) as? T else {
                throw NSError(domain: "Object ID로 Object 찾기 실패", code: -1)
            }
            return object
        }
    }
}

extension ChatPersistenceManager: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue = ChatPersistenceManager()
}

extension EnvironmentValues {
    var chatPersistenceManager: ChatPersistenceManager {
        get { self[ChatPersistenceManager.self] }
        set { self[ChatPersistenceManager.self] = newValue }
    }
}
