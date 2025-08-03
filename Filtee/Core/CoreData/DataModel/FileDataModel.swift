//
//  FileDataModel.swift
//  Filtee
//
//  Created by 김도형 on 7/12/25.
//

import Foundation
import CoreData

@objc(FileDataModel)
public class FileDataModel: NSManagedObject, @unchecked Sendable {
    
    // MARK: - Convenience Initializers
    convenience init(context: NSManagedObjectContext,
                     id: String,
                     data: Data?,
                     type: String?,
                     url: String,
                     sequence: Int16 = 0) {
        self.init(context: context)
        self.id = id
        self.data = data
        self.type = type
        self.url = url
        self.sequence = sequence
    }
}

// MARK: - FileDataModel+CoreDataProperties.swift
extension FileDataModel {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FileDataModel> {
        return NSFetchRequest<FileDataModel>(entityName: "FileDataModel")
    }
    
    @NSManaged public var id: String
    @NSManaged public var data: Data?
    @NSManaged public var type: String?
    @NSManaged public var url: String
    @NSManaged public var sequence: Int16
}

extension FileDataModel {
    func toModel() -> FileModel {
        return FileModel(
            id: self.id,
            sequence: self.sequence,
            data: self.data,
            type: self.type,
            url: self.url
        )
    }
}
