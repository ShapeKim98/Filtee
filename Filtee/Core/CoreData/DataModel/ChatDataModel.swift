//
//  ChatDataModel.swift
//  Filtee
//
//  Created by 김도형 on 7/12/25.
//

import Foundation
import CoreData

@objc(ChatDataModel)
public class ChatDataModel: NSManagedObject, @unchecked Sendable {
    
    // MARK: - Convenience Initializers
    convenience init(context: NSManagedObjectContext,
                    chatId: String,
                    content: String,
                    roomId: String,
                    isFirst: Bool = false,
                    sender: SenderDataModel? = nil) {
        self.init(context: context)
        self.chatId = chatId
        self.content = content
        self.roomId = roomId
        self.createdAt = Date()
        self.isFirst = isFirst
        self.sender = sender
    }
}

// MARK: - ChatDataModel+CoreDataProperties.swift
extension ChatDataModel {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatDataModel> {
        return NSFetchRequest<ChatDataModel>(entityName: "ChatDataModel")
    }
    
    // MARK: - Required Properties
    @NSManaged public var chatId: String
    @NSManaged public var content: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var isFirst: Bool
    @NSManaged public var isLast: Bool
    @NSManaged public var roomId: String
    
    // MARK: - Optional Properties
    @NSManaged public var filesData: Data?
    
    // MARK: - Relationships
    @NSManaged public var sender: SenderDataModel?
}

extension ChatDataModel {
    func toModel() -> ChatModel {
        return ChatModel(
            id: self.chatId,
            roomId: self.roomId,
            content: self.content,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            sender: self.sender?.toModel(),
            isFirst: self.isFirst,
            isLast: self.isLast
        )
    }
}
