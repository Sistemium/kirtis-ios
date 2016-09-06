//
//  StartupDataSyncService.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 23/03/16.
//  Copyright © 2016 Sistemium. All rights reserved.
//

import UIKit
import CoreData

class StartupDataSyncService {
    static let sharedInstance = StartupDataSyncService()
    private init() {
        loadDictionary()
    }
    var groups : [GroupOfAbbreviations] = []
    var dictionary : [Abbreviation] = []
    var dictionaryInitiated = false
    
    func loadDictionary(){
        _ = try? fetch()
        let api:String = Constants.dictionaryAPI
        let rez = RestService.sharedInstance.getJSON(api, cashingKey: "dictionary")
        if rez.statusCode == nil{
            return
        }
        dictionaryInitiated = true
        if rez.statusCode == HTTPStatusCode.NotModified{
            return
        }
        for group in groups{
            CoreDataService.sharedInstance.managedObjectContext.deleteObject(group)
        }
        for dict in dictionary{
            CoreDataService.sharedInstance.managedObjectContext.deleteObject(dict)
        }
        groups = []
        dictionary = []
        if let json = rez.json  {
            if let data = RestService.sharedInstance.parseJSONDictionary(json){
                let entity =  NSEntityDescription.entityForName("GroupOfAbbreviations",
                    inManagedObjectContext:CoreDataService.sharedInstance.managedObjectContext)
                let mainGroup = GroupOfAbbreviations(entity: entity!,
                    insertIntoManagedObjectContext: CoreDataService.sharedInstance.managedObjectContext)
                mainGroup.name = "Dictionary"
                pushData(data,parentGroup: mainGroup)
                _ = try? CoreDataService.sharedInstance.managedObjectContext.save()
            } else{
                dictionaryInitiated = false
            }
        }
        _ = try? fetch()
    }
    
    private func fetch() throws{
        let groupFetchRequest = NSFetchRequest(entityName: "GroupOfAbbreviations")
        let dictionaryFetchRequest = NSFetchRequest(entityName: "Abbreviation")
        let results1 =
        try CoreDataService.sharedInstance.managedObjectContext.executeFetchRequest(groupFetchRequest)
        let results2 =
        try CoreDataService.sharedInstance.managedObjectContext.executeFetchRequest(dictionaryFetchRequest)
        groups = results1 as! [GroupOfAbbreviations]
        dictionary = results2 as! [Abbreviation]
    }
    
    private func pushData(data:NSDictionary,parentGroup:GroupOfAbbreviations){
        for d in data {
            if let value = d.value as? NSDictionary {
                let entity =  NSEntityDescription.entityForName("GroupOfAbbreviations",
                    inManagedObjectContext:CoreDataService.sharedInstance.managedObjectContext)
                let group = GroupOfAbbreviations(entity: entity!,
                    insertIntoManagedObjectContext: CoreDataService.sharedInstance.managedObjectContext)
                group.setValue(d.key, forKey: "name")
                parentGroup.subgroup.setValue(group, forKey: group.name!)
                pushData(value,parentGroup: group)
            }else{
                let entity =  NSEntityDescription.entityForName("Abbreviation",
                    inManagedObjectContext:CoreDataService.sharedInstance.managedObjectContext)
                let dictionary = NSManagedObject(entity: entity!,
                    insertIntoManagedObjectContext: CoreDataService.sharedInstance.managedObjectContext)
                dictionary.setValue(d.key, forKey: "shortForm")
                dictionary.setValue(d.value, forKey: "longForm")
                dictionary.setValue(parentGroup, forKey: "group")
            }
        }
    }
}
