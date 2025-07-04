//
//  ChatClient.swift
//  Filtee
//
//  Created by 김도형 on 6/24/25.
//

import SwiftUICore
@preconcurrency import CoreData

actor ChatPersistenceManager {
    private let context = PersistenceProvider.shared.container.newBackgroundContext()
    
    func paginationChatGroups(roomId: String, cursor: Date?, page: Int = 20) async throws -> [ChatGroupModel]? {
        let context = self.context
        return try await context.perform { @Sendable in
            let request: NSFetchRequest<ChatGroupModel> = ChatGroupModel.fetchRequest()
            
            // 정렬: 최신순
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \ChatGroupModel.latestedAt, ascending: false)
            ]
            
            // 필터 조건
            var predicates: [NSPredicate] = []
            
            // 방 필터링
            predicates.append(NSPredicate(format: "room.roomId == %@", roomId))
            
            // 커서 기반 페이지네이션
            if let cursor = cursor {
                predicates.append(NSPredicate(format: "latestedAt < %@", cursor as NSDate))
            }
            
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            request.fetchLimit = page
            
            request.includesPropertyValues = true
            request.returnsObjectsAsFaults = false
            
            return try context.fetch(request)
        }
    }
    
    @discardableResult
    func createChat(
        chatId: String,
        content: String,
        room: RoomModel,
        sender: SenderModel,
        filesData: Data? = nil,
        createdAt: Date,
        updatedAt: Date,
        lastChatGroup: ChatGroupModel?
    ) async throws -> ChatGroupModel {
        let senderObject: SenderModel = try await read(sender.objectID)
        let roomObject: RoomModel = try await read(room.objectID)
        
        let chat: ChatModel = try await save { context in
            let chat = ChatModel(context: context)
            chat.chatId = chatId
            chat.content = content
            chat.roomId = roomObject.roomId
            chat.sender = senderObject
            chat.filesData = filesData
            chat.createdAt = createdAt
            chat.updatedAt = updatedAt
            return chat
        }
        let targetGroup: ChatGroupModel
        if let lastChatGroup,
            let latestedAt = lastChatGroup.latestedAt,
           lastChatGroup.sender?.userId == sender.userId {
            let calendar = Calendar.current
            let lastMinute = calendar.component(.minute, from: latestedAt)
            let currentMinute = calendar.component(.minute, from: createdAt)
            let lastHour = calendar.component(.hour, from: latestedAt)
            let currentHour = calendar.component(.hour, from: createdAt)
            let lastDay = calendar.component(.day, from: latestedAt)
            let currentDay = calendar.component(.day, from: createdAt)
            let isNewGroup = lastDay != currentDay || lastHour != currentHour || lastMinute != currentMinute
            
            if isNewGroup {
                targetGroup = try await _createChatGroup(sender: senderObject, in: roomObject)
            } else {
                targetGroup = lastChatGroup
            }
        } else {
            targetGroup = try await _createChatGroup(sender: senderObject, in: roomObject)
        }
        try await _updateChatGroup(chat: chat, in: targetGroup)
        
        return targetGroup
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
    
    private func save<T: Sendable>(_ block: @Sendable @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        let context = self.context
        let object = try await context.perform { @Sendable in
            let object = try block(context)
            
            guard context.hasChanges else {
                throw NSError(domain: "Context 변경 사항 없음", code: -1)
            }
            
            try context.save()
            
            return object
        }
        
        return object
    }
    
    private func read<T: Sendable>(_ objectId: NSManagedObjectID) async throws -> T {
        let context = self.context
        return try await context.perform { @Sendable in
            guard let object = context.object(with: objectId) as? T else {
                throw NSError(domain: "Object ID로 Object 찾기 실패", code: -1)
            }
            return object
        }
    }
}

extension ChatPersistenceManager: EnvironmentKey {
    static let defaultValue = ChatPersistenceManager()
}

extension EnvironmentValues {
    var chatPersistenceManager: ChatPersistenceManager {
        get { self[ChatPersistenceManager.self] }
        set { self[ChatPersistenceManager.self] = newValue }
    }
}
