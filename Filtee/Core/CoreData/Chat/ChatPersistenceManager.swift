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
    
    func paginationChat(roomId: String, cursor: Date?, page: Int = 20) async throws -> [ChatModel]? {
        let context = self.context
        return try await context.perform { @Sendable in
            let request: NSFetchRequest<ChatDataModel> = ChatDataModel.fetchRequest()
            
            // 정렬: 최신순
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \ChatDataModel.createdAt, ascending: false)
            ]
            
            // 필터 조건
            var predicates: [NSPredicate] = []
            
            // 방 필터링
            predicates.append(NSPredicate(format: "roomId == %@", roomId))
            
            // 커서 기반 페이지네이션
            if let cursor = cursor {
                predicates.append(NSPredicate(format: "createdAt < %@", cursor as NSDate))
            }
            
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            request.fetchLimit = page
            
            request.includesPropertyValues = true
            request.returnsObjectsAsFaults = false
            
            return try context.fetch(request).map { $0.toModel() }
        }
    }
    
    func fetchChatFromDateToDate(
        from fromDate: Date,
        to toDate: Date,
        in roomId: String
    ) throws -> [ChatModel] {
        let request: NSFetchRequest<ChatDataModel> = ChatDataModel.fetchRequest()
        
        var predicates: [NSPredicate] = []
        
        // 날짜 범위 설정 (fromDate < latestedAt < toDate)
        let datePredicate = NSPredicate(
            format: "createdAt < %@ AND createdAt >= %@",
            fromDate as NSDate,
            toDate as NSDate
        )
        predicates.append(datePredicate)
        
        let roomPredicate = NSPredicate(format: "roomId == %@", roomId)
        predicates.append(roomPredicate)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        // 내림차순 정렬 (최신 → 과거)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ChatDataModel.createdAt, ascending: false)
        ]
        
        return try context.fetch(request).map { $0.toModel() }
    }
    
    func searchChat(_ keyword: String, roomId: String) async throws -> [ChatModel] {
        let context = self.context
        return try await context.perform { @Sendable in
            let request: NSFetchRequest<ChatDataModel> = ChatDataModel.fetchRequest()
            
            // 정렬: 최신순
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \ChatDataModel.createdAt, ascending: false)
            ]
            
            // 필터 조건
            var predicates: [NSPredicate] = []
            
            // 방 필터링
            let keywordPredicate = NSPredicate(format: "ANY content CONTAINS[cd] %@", keyword)
            predicates.append(keywordPredicate)
            predicates.append(NSPredicate(format: "roomId == %@", roomId))
            
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            
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
        roomModel: RoomModel
    ) async throws -> ChatModel {
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
        
        if let lastChat = room.lastChat,
           lastChat.sender?.userId == sender.userId {
            let calendar = Calendar.current
            let lastMinute = calendar.component(.minute, from: lastChat.createdAt)
            let currentMinute = calendar.component(.minute, from: chatModel.createdAt)
            let lastHour = calendar.component(.hour, from: lastChat.createdAt)
            let currentHour = calendar.component(.hour, from: chatModel.createdAt)
            let lastDay = calendar.component(.day, from: lastChat.createdAt)
            let currentDay = calendar.component(.day, from: chatModel.createdAt)
            let lastYear = calendar.component(.year, from: lastChat.createdAt)
            let currentYear = calendar.component(.year, from: chatModel.createdAt)
            
            let isFirst = lastDay != currentDay
            || lastHour != currentHour
            || lastMinute != currentMinute
            || lastYear != currentYear
            
            print(chat.content, isFirst)
            
            try await save { _ in
                chat.isFirst = isFirst
                lastChat.isLast = isFirst
            }
        }
        
        try await _updateRoom(chat: chat, in: room)
        
        return chat.toModel()
    }
    
    private func _readRoom(_ id: String) async throws -> RoomDataModel {
        return try await read(id, query: "roomId == %@", of: RoomDataModel.self)
    }
    
    private func _readSender(_ id: String) async throws -> SenderDataModel {
        return try await read(id, query: "userId == %@", of: SenderDataModel.self)
    }
    
    private func _readChat(_ id: String) async throws -> ChatDataModel {
        return try await read(id, query: "chatId == %@", of: ChatDataModel.self)
    }
    
    @discardableResult
    private func _updateRoom(
        chat: ChatDataModel,
        in room: RoomDataModel
    ) async throws -> RoomDataModel {
        return try await save { _ in
            room.lastChat = chat
            room.addToChats(chat)
            return room
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
    
    @discardableResult
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
