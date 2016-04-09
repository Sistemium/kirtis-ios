//
//  LocalizationService.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 23/03/16.
//  Copyright © 2016 Sistemium. All rights reserved.
//

import UIKit

class LocalizationService{
    static let sharedInstance = LocalizationService()
    private init() {}
    var userLanguage: String{
        set{
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(newValue, forKey: "Language")
            let storyBoard = UIStoryboard(name:"Main", bundle: NSBundle.mainBundle())
            (UIApplication.sharedApplication().delegate as! AppDelegate).window!.rootViewController = storyBoard.instantiateViewControllerWithIdentifier("root")
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
            }
            return "en"
        }
    }
    
    func localize(key:String) -> String {
        return NSLocalizedString(key, bundle: NSBundle(path:NSBundle.mainBundle().pathForResource(userLanguage , ofType:"lproj")!)!, value: "", comment: "")
    }
}
