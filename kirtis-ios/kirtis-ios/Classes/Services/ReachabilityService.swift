//
//  ReachabilityService.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 23/03/16.
//  Copyright © 2016 Sistemium. All rights reserved.
//

import UIKit
import ReachabilitySwift

class ReachabilityService{
    static let sharedInstance = ReachabilityService()
    private init() {
        do{
            reachability = try Reachability.reachabilityForInternetConnection()
            try reachability?.startNotifier();
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
        }catch let error as NSError {
            print("\(error), \(error.userInfo)")
        }
    }
    var reachability :Reachability?
    
    @objc private func reachabilityChanged(note: NSNotification?){
        if hasConnectivity(){
            if !StartupDataSyncService.sharedInstance.dictionaryInitiated{
                StartupDataSyncService.sharedInstance.loadDictionary()
            }
        }
    }
    
    func hasConnectivity() -> Bool {
        let networkStatus: Int = ReachabilityService.sharedInstance.reachability!.currentReachabilityStatus.hashValue
        return networkStatus != 0
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
