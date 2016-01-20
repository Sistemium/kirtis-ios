//
//  AppDelegate.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 11/11/15.
//  Copyright © 2015 Edgar Jan Vuicik. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import CoreData
import ReachabilitySwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var reachability :Reachability?
    var window: UIWindow?
    var groups : [Group] = []
    var dictionary : [Dictionary] = []
    var dictionaryInitiated = false
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private var eTag:String?{
        get{
            return defaults.objectForKey("eTag") as? String ?? nil
        }
        set{
            defaults.setObject(newValue, forKey: "eTag")
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self()])
        do{
            reachability = try Reachability.reachabilityForInternetConnection()
            try reachability?.startNotifier();
        }catch let error as NSError {
            print("\(error), \(error.userInfo)")
        }
        loadDictionary()
        return true
    }
    
    func loadDictionary(){
        do {
            try fetch()
            let api:String = "http://kirtis.info/api/strp"
            let rez = getJSON(api, cashed: true)
            if rez.statusCode == -1{
                return
            }
            
            dictionaryInitiated = true
            if rez.statusCode == 304{
                return
            }
            if let json = rez.json  {
                let data = parseJSONDictionary(json)
                let entity =  NSEntityDescription.entityForName("Group",
                    inManagedObjectContext:managedObjectContext)
                let mainGroup = Group(entity: entity!,
                    insertIntoManagedObjectContext: managedObjectContext)
                mainGroup.name = "Dictionary"
                pushData(data!,parentGroup: mainGroup)
                try managedObjectContext.save()
            }
            try fetch()
        } catch let error as NSError {
            print("\(error), \(error.userInfo)")
        }
    }
    
    private func fetch() throws{
        let groupFetchRequest = NSFetchRequest(entityName: "Group")
        let dictionaryFetchRequest = NSFetchRequest(entityName: "Dictionary")
        let results1 =
        try managedObjectContext.executeFetchRequest(groupFetchRequest)
        let results2 =
        try managedObjectContext.executeFetchRequest(dictionaryFetchRequest)
        let groups = results1 as! [Group]
        let dictionary = results2 as! [Dictionary]
        self.groups = groups
        self.dictionary = dictionary
    }
    
    private func pushData(data:NSDictionary,parentGroup:Group){
        for d in data {
            if let value = d.value as? NSDictionary {
                let entity =  NSEntityDescription.entityForName("Group",
                    inManagedObjectContext:managedObjectContext)
                let group = Group(entity: entity!,
                    insertIntoManagedObjectContext: managedObjectContext)
                group.setValue(d.key, forKey: "name")
                parentGroup.subgroup.setValue(group, forKey: group.name!)
                pushData(value,parentGroup: group)
            }else{
                let entity =  NSEntityDescription.entityForName("Dictionary",
                    inManagedObjectContext:managedObjectContext)
                let dictionary = NSManagedObject(entity: entity!,
                    insertIntoManagedObjectContext: managedObjectContext)
                dictionary.setValue(d.key, forKey: "key")
                dictionary.setValue(d.value, forKey: "value")
                dictionary.setValue(parentGroup, forKey: "group")
            }
        }
    }
    
    func logUser() {
        // TODO: Use the current user's information
        // You can call any combination of these three methods
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
    }

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "uk.co.plymouthsoftware.core_data" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("kirtis-ios.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

    var userLanguage: String{
        set{
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(newValue, forKey: "Language")
        defaults.synchronize()
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        self.window?.rootViewController = storyboard.instantiateInitialViewController()
        }
        
        get{
            let defaults = NSUserDefaults.standardUserDefaults();
            if let lng = defaults.stringForKey("Language"){
                return lng
            }
            for lng in NSLocale.preferredLanguages(){
                if lng.hasPrefix("lt"){
                    return "lt"
                }
                if lng.hasPrefix("ru"){
                    return "ru"
                }
                if lng.hasPrefix("en"){
                    return "Base"
                }
            }
            return "Base"
        }
    }
    
    func getJSON(urlToRequest: String, cashed : Bool = false) -> (json : NSData?,statusCode : Int!){
        var response: NSURLResponse?
        do{
            if let url = NSURL(string: urlToRequest){
                let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: 4.0)
                if cashed{
                    request.addValue(eTag ?? "", forHTTPHeaderField: "If-None-Match")
                }
                let rez = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
                eTag = (response as! NSHTTPURLResponse).allHeaderFields["eTag"] as? String
                return (rez,(response as! NSHTTPURLResponse).statusCode)
            }
        }
        catch{
            
        }
        return (nil , -1)
    }
    
    func parseJSON(inputData: NSData) -> NSArray?{
        do{
            let jsonDict = try NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions(rawValue: 0)) as! NSArray //what if it fails?
            return jsonDict
        }catch let parseError {
            print(parseError)
        }
        return nil
    }
    
    func parseJSONDictionary(inputData: NSData) -> NSDictionary?{
        do{
            let jsonDict = try NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions(rawValue: 0)) as! NSDictionary //what if it fails?
            return jsonDict
        }catch let parseError {
            print(parseError)
        }
        return nil
    }
    
}

