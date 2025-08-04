//
//  RoomDataModel.swift
//  Filtee
//
//  Created by 김도형 on 7/12/25.
//

import Foundation
import CoreData

@objc(RoomDataModel)
public class RoomDataModel: NSManagedObject, @unchecked Sendable {
    
    // MARK: - Convenience Initializers
    convenience init(context: NSManagedObjectContext,
                    roomId: String) {
        self.init(context: context)
        self.roomId = roomId
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - RoomDataModel+CoreDataProperties.swift
extension RoomDataModel {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<RoomDataModel> {
        return NSFetchRequest<RoomDataModel>(entityName: "RoomDataModel")
    }
    
    // MARK: - Required Properties
    @NSManaged public var createdAt: Date
    @NSManaged public var roomId: String
    @NSManaged public var updatedAt: Date
    
    // MARK: - Relationships
    @NSManaged public var chats: NSSet?
    @NSManaged public var lastChat: ChatDataModel?
    @NSManaged public var participants: NSSet?
}

// MARK: - Generated accessors for chats
extension RoomDataModel {
    
    @objc(addChatsObject:)
    @NSManaged public func addToChats(_ value: ChatDataModel)
    
    @objc(removeChatsObject:)
    @NSManaged public func removeFromChats(_ value: ChatDataModel)
    
    @objc(addChats:)
    @NSManaged public func addToChats(_ values: NSSet)
    
    @objc(removeChats:)
    @NSManaged public func removeFromChats(_ values: NSSet)
}

// MARK: - Generated accessors for participants
extension RoomDataModel {
    
    @objc(addParticipantsObject:)
    @NSManaged public func addToParticipants(_ value: SenderDataModel)
    
    @objc(removeParticipantsObject:)
    @NSManaged public func removeFromParticipants(_ value: SenderDataModel)
    
    @objc(addParticipants:)
    @NSManaged public func addToParticipants(_ values: NSSet)
    
    @objc(removeParticipants:)
    @NSManaged public func removeFromParticipants(_ values: NSSet)
}

extension RoomDataModel {
    func toModel() -> RoomModel {
        let senderSet = self.participants as? Set<SenderDataModel> ?? []
        let senders = senderSet.sorted { $0.nick ?? "" < $1.nick ?? "" }
        
        return RoomModel(
            id: self.roomId,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            participants: senders.map { $0.toModel() },
            lastChat: self.lastChat?.toModel()
        )
    }
}
