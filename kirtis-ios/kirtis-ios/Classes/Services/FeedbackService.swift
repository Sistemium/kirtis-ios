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
    fileprivate init() {
    }
    
    fileprivate var launches:Int{
        get{
            return UserDefaults.standard.value(forKey: "FeedbackServiceLaunches") as? Int ?? 0
        }
        set{
            UserDefaults.standard.setValue(newValue, forKey: "FeedbackServiceLaunches")
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
    
    func rateAppFromViewController(_ viewController:UIViewController){
        let alertController = UIAlertController(title: "PLEASERATE".localized, message: "IFYOULIKE".localized, preferredStyle: .alert)
        let no = UIAlertAction(title: "NOTHX".localized, style: .cancel) { _ in 
            self.launches = 8
        }
        alertController.addAction(no)
        let rate = UIAlertAction(title: "RATEIT".localized, style: .default) { _ in
            self.rateApp()
        }
        alertController.addAction(rate)
        let remind = UIAlertAction(title: "REMINDME".localized, style: .default) { _ in
            self.launches = 0
        }
        alertController.addAction(remind)
        viewController.present(alertController, animated: true) {
        }
    }
    
    func rateApp(){
        UIApplication.shared.openURL(URL(string : Constants.appStoreRateURL)!)
        launches = 8
    }
}
