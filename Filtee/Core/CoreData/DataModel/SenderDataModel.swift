//
//  SenderDataModel.swift
//  Filtee
//
//  Created by 김도형 on 7/12/25.
//

import Foundation
import CoreData

@objc(SenderDataModel)
public class SenderDataModel: NSManagedObject, @unchecked Sendable {
    
    // MARK: - Convenience Initializers
    convenience init(context: NSManagedObjectContext,
                    userId: String,
                    nick: String,
                    profileImage: String) {
        self.init(context: context)
        self.userId = userId
        self.nick = nick
        self.profileImage = profileImage
    }
}

// MARK: - SenderDataModel+CoreDataProperties.swift
extension SenderDataModel {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SenderDataModel> {
        return NSFetchRequest<SenderDataModel>(entityName: "SenderDataModel")
    }
    
    // MARK: - Required Properties
    @NSManaged public var nick: String
    @NSManaged public var userId: String
    
    @NSManaged public var profileImage: String?
}

extension SenderDataModel {
    func toModel() -> UserInfoModel {
        return UserInfoModel(
            id: self.userId,
            nick: self.nick,
            profileImage: self.profileImage ?? "",
            name: nil,
            hashTags: []
        )
    }
}
