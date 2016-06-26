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
        reachability = try? Reachability.reachabilityForInternetConnection()
        _ = try? reachability?.startNotifier();
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ReachabilityService.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: reachability)
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
