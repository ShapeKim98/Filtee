//
//  PersistenceProvider.swift
//  Filtee
//
//  Created by 김도형 on 6/18/25.
//

import Foundation
import CoreData

final class PersistenceProvider: Sendable {
    static let shared = PersistenceProvider()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ChatDataModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
