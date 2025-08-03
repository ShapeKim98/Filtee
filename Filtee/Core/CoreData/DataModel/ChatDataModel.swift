//
//  ChatDataModel.swift
//  Filtee
//
//  Created by 김도형 on 7/12/25.
//

import Foundation
import CoreData

import IdentifiedCollections

@objc(ChatDataModel)
public class ChatDataModel: NSManagedObject, @unchecked Sendable {
    
    // MARK: - Convenience Initializers
    convenience init(context: NSManagedObjectContext,
                     chatId: String,
                     content: String,
                     roomId: String,
                     isHead: Bool = false,
                     isTail: Bool = true,
                     sender: SenderDataModel? = nil) {
        self.init(context: context)
        self.chatId = chatId
        self.content = content
        self.roomId = roomId
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isHead = isHead
        self.isTail = isTail
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
    @NSManaged public var isHead: Bool
    @NSManaged public var isTail: Bool
    @NSManaged public var roomId: String
    
    // MARK: - Relationships
    @NSManaged public var files: NSSet?
    @NSManaged public var sender: SenderDataModel?
}

// MARK: - Generated accessors for files
extension ChatDataModel {
    
    @objc(addFilesObject:)
    @NSManaged public func addToFiles(_ value: FileDataModel)
    
    @objc(removeFilesObject:)
    @NSManaged public func removeFromFiles(_ value: FileDataModel)
    
    @objc(addFiles:)
    @NSManaged public func addToFiles(_ values: NSSet)
    
    @objc(removeFiles:)
    @NSManaged public func removeFromFiles(_ values: NSSet)
}

extension ChatDataModel {
    func toModel() -> ChatModel {
        let files = self.files as? Set<FileDataModel> ?? []
        let fileModels = files.sorted { $0.sequence < $1.sequence }.map { $0.toModel() }
        
        return ChatModel(
            id: self.chatId,
            roomId: self.roomId,
            content: self.content,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            sender: self.sender?.toModel(),
            isHead: self.isHead,
            isTail: self.isTail,
            files: IdentifiedArray(uniqueElements: fileModels)
        )
    }
}
