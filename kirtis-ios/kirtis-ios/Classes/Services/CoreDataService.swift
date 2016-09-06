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
    private init() {} 
    
    lazy var managedObjectContext: NSManagedObjectContext = {[unowned self] in
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            _ = try? managedObjectContext.save()
        }
    }
    
    private lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {[unowned self] in
        let oldUrl = self.applicationDocumentsDirectory.URLByAppendingPathComponent("kirtis-ios.sqlite")
        if NSFileManager.defaultManager().fileExistsAtPath(oldUrl.path!){
                _ = try? NSFileManager.defaultManager().removeItemAtURL(oldUrl)
        }
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("kirtis-ios_v2.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        _ = try? coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        return coordinator
    }()
}