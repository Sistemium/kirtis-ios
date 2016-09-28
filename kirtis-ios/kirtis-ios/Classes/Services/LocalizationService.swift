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
    fileprivate init() {}
    var userLanguage: String{
        set{
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "Language")
            let storyBoard = UIStoryboard(name:"Main", bundle: Bundle.main)
            (UIApplication.shared.delegate as! AppDelegate).window!.rootViewController = storyBoard.instantiateViewController(withIdentifier: "root")
        }
        get{
            let defaults = UserDefaults.standard;
            if let lng = defaults.string(forKey: "Language"){
                if lng.hasPrefix("lt") || lng.hasPrefix("ru") || lng.hasPrefix("en"){
                    return lng
                }
            }
            for lng in Locale.preferredLanguages{
                if lng.hasPrefix("en"){
                    return "en"
                }
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
    
    func localize(_ key:String) -> String {
        return NSLocalizedString(key, bundle: Bundle(path:Bundle.main.path(forResource: userLanguage , ofType:"lproj")!)!, value: "", comment: "")
    }
}
