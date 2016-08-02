//
//  FeedbackService.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 06/04/16.
//  Copyright © 2016 Sistemium. All rights reserved.
//

import UIKit

class FeedbackService{
    static let sharedInstance = FeedbackService()
    private init() {
    }
    
    private var launches:Int{
        get{
            return NSUserDefaults.standardUserDefaults().valueForKey("FeedbackServiceLaunches") as? Int ?? 0
        }
        set{
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "FeedbackServiceLaunches")
        }
    }
    
    func needsRateApp() -> Bool{
        launches = launches + 1
        if launches == 7{
            launches = 0
            return true
        }
        return false
    }
    
    func rateAppFromViewController(viewController:UIViewController){
        let alertController = UIAlertController(title: "PLEASERATE".localized, message: "IFYOULIKE".localized, preferredStyle: .Alert)
        let no = UIAlertAction(title: "NOTHX".localized, style: .Cancel) { _ in
            self.launches = 8
        }
        alertController.addAction(no)
        let rate = UIAlertAction(title: "RATEIT".localized, style: .Default) { _ in
            self.rateApp()
        }
        alertController.addAction(rate)
        let remind = UIAlertAction(title: "REMINDME".localized, style: .Default) { _ in
            self.launches = 0
        }
        alertController.addAction(remind)
        viewController.presentViewController(alertController, animated: true) {
        }
    }
    
    func rateApp(){
        UIApplication.sharedApplication().openURL(NSURL(string : Constants.appStoreRateURL)!)
        self.launches = 8
    }
}
