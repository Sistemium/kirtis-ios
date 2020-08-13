//
//  ReachabilityService.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 23/03/16.
//  Copyright © 2016 Sistemium. All rights reserved.
//

import UIKit
import Reachability

class ReachabilityService{
    static let sharedInstance = ReachabilityService()
    fileprivate init() {
        reachability = Reachability()
        _ = ((try? reachability?.startNotifier()) as ()??);
        NotificationCenter.default.addObserver(self, selector: #selector(ReachabilityService.reachabilityChanged(_:)), name: NSNotification.Name.reachabilityChanged, object: reachability)
    }
    var reachability :Reachability?
    
    @objc fileprivate func reachabilityChanged(_ note: Notification?){
        if hasConnectivity(){
            DispatchQueue.main.async(execute: {
                if !StartupDataSyncService.sharedInstance.dictionaryInitiated{
                    StartupDataSyncService.sharedInstance.loadDictionary()
                }
            })
        }
    }
    
    func hasConnectivity() -> Bool {
        let networkStatus: Int = ReachabilityService.sharedInstance.reachability!.connection.hashValue
        return networkStatus != 0
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
}
