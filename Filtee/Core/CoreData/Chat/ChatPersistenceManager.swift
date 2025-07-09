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
            let request: NSFetchRequest<ChatGroupDataModel> = ChatGroupDataModel.fetchRequest()
            
            // 정렬: 최신순
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \ChatGroupDataModel.latestedAt, ascending: false)
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
            
            return try context.fetch(request).map { $0.toModel() }
        }
    }
    
    func readRoom(_ id: String) async throws -> RoomModel {
        return try await _readRoom(id).toModel()
    }
    
    func createRoom(_ roomModel: RoomModel) async throws -> RoomModel {
        if let room = try? await readRoom(roomModel.id) {
            return room
        } else {
            return try await _createRoom(roomModel: roomModel).toModel()
        }
    }
    
    func createChat(
        chatModel: ChatModel,
        lastChatGroup: ChatGroupModel?
    ) async throws -> ChatGroupModel {
        let room = try await _readRoom(chatModel.roomId)
        let sender = try await _readSender(chatModel.sender?.id ?? "")
        
        let chat: ChatDataModel = try await save { context in
            let chat = ChatDataModel(context: context)
            chat.chatId = chatModel.id
            chat.content = chatModel.content
            chat.roomId = chatModel.roomId
            chat.sender = sender
            chat.filesData = nil
            chat.createdAt = chatModel.createdAt
            chat.updatedAt = chatModel.updatedAt
            return chat
        }
        let targetGroup: ChatGroupDataModel
        if let lastChatGroup, lastChatGroup.sender?.id == sender.userId {
            let calendar = Calendar.current
            let lastMinute = calendar.component(.minute, from: lastChatGroup.latestedAt)
            let currentMinute = calendar.component(.minute, from: chatModel.createdAt)
            let lastHour = calendar.component(.hour, from: lastChatGroup.latestedAt)
            let currentHour = calendar.component(.hour, from: chatModel.createdAt)
            let lastDay = calendar.component(.day, from: lastChatGroup.latestedAt)
            let currentDay = calendar.component(.day, from: chatModel.createdAt)
            let isNewGroup = lastDay != currentDay || lastHour != currentHour || lastMinute != currentMinute
            
            if isNewGroup {
                targetGroup = try await _createChatGroup(
                    chat: chat,
                    sender: sender,
                    in: room
                )
            } else {
                print(chatModel.createdAt, lastChatGroup.latestedAt, lastChatGroup.id)
                targetGroup = try await _readChatGroup(lastChatGroup.id)
                try await _updateChatGroup(chat: chat, in: targetGroup)
            }
        } else {
            targetGroup = try await _createChatGroup(
                chat: chat,
                sender: sender,
                in: room
            )
        }
        
        return targetGroup.toModel()
    }
    
    private func _readRoom(_ id: String) async throws -> RoomDataModel {
        return try await read(id, query: "roomId == %@", of: RoomDataModel.self)
    }
    
    private func _readSender(_ id: String) async throws -> SenderDataModel {
        return try await read(id, query: "userId == %@", of: SenderDataModel.self)
    }
    
    private func _readChatGroup(_ id: String) async throws -> ChatGroupDataModel {
        return try await read(id, query: "id == %@", of: ChatGroupDataModel.self)
    }
    
    /// 채팅 그룹 업데이트 (latestedAt 갱신)
    @discardableResult
    private func _updateChatGroup(
        chat: ChatDataModel,
        in chatGroup: ChatGroupDataModel
    ) async throws -> ChatGroupDataModel {
        return try await save { context in
            chatGroup.addToChats(chat)
            chatGroup.latestedAt = chat.createdAt
            return chatGroup
        }
    }
    
    @discardableResult
    private func _createChatGroup(
        chat: ChatDataModel,
        sender: SenderDataModel,
        in room: RoomDataModel
    ) async throws -> ChatGroupDataModel {
        return try await save { context in
            let chatGroup = ChatGroupDataModel(context: context)
            chatGroup.id = UUID().uuidString
            chatGroup.sender = sender
            chatGroup.addToChats(chat)
            chatGroup.latestedAt = chat.createdAt
            
            room.addToChats(chatGroup)
            return chatGroup
        }
    }
    
    @discardableResult
    private func _createRoom(roomModel: RoomModel) async throws -> RoomDataModel {
        var participants: [SenderDataModel] = []
        for sender in roomModel.participants {
            let newSender = try await _createSender(
                userId: sender.id,
                nick: sender.nick,
                profileImage: sender.profileImage
            )
            participants.append(newSender)
        }
        
        return try await save { [participants] context in
            let room = RoomDataModel(context: context)
            room.roomId = roomModel.id
            room.createdAt = roomModel.createdAt
            room.updatedAt = roomModel.updatedAt
            room.chats = []
            for sender in participants {
                room.addToParticipants(sender)
            }
            
            return room
        }
    }
    
    
    /// 새 발신자 생성
    @discardableResult
    private func _createSender(
        userId: String,
        nick: String,
        profileImage: String? = nil
    ) async throws -> SenderDataModel {
        return try await save { context in
            let sender = SenderDataModel(context: context)
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
    
    private func read<I: CVarArg, O: NSManagedObject>(
        _ id: I,
        query: String,
        of: O.Type
    ) async throws -> O {
        let request: NSFetchRequest<O> = NSFetchRequest(entityName: O.description())
        request.predicate = NSPredicate(format: query, id)
        guard let object = try context.fetch(request).first else {
            throw NSError(domain: "Query로 Object 찾기 실패, \(O.description())", code: -1)
        }
        return object
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
