//
//  CoreDataService.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 23/03/16.
//  Copyright © 2016 Sistemium. All rights reserved.
//

import UIKit
import CoreData

class CoreDataService {
    static let sharedInstance = CoreDataService()
    fileprivate init() {} 
    
    lazy var managedObjectContext: NSManagedObjectContext = {[unowned self] in
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            _ = try? managedObjectContext.save()
        }
    }
    
    fileprivate lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    fileprivate lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    fileprivate lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {[unowned self] in
        let oldUrl = self.applicationDocumentsDirectory.appendingPathComponent("kirtis-ios.sqlite")
        if FileManager.default.fileExists(atPath: oldUrl.path){
                _ = try? FileManager.default.removeItem(at: oldUrl)
        }
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("kirtis-ios_v2.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        _ = try? coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        return coordinator
    }()
}
