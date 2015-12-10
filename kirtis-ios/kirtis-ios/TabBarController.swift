//
//  TabBarController.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 26/11/15.
//  Copyright © 2015 Sistemium. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let currentLanguageBundle = NSBundle(path:NSBundle.mainBundle().pathForResource(self.appDelegate.userLanguage , ofType:"lproj")!)
        self.viewControllers?[0].tabBarItem.image = UIImage(named: NSLocalizedString("Home", bundle: currentLanguageBundle!, value: "Home", comment: "Home"))
        self.viewControllers?[1].tabBarItem.image = UIImage(named: NSLocalizedString("Settings", bundle: currentLanguageBundle!, value: "Settings", comment: "Settings"))
        self.viewControllers?[2].tabBarItem.image = UIImage(named: NSLocalizedString("Dictionary", bundle: currentLanguageBundle!, value: "Dictionary", comment: "Dictionary"))
        self.viewControllers?[3].tabBarItem.image = UIImage(named: NSLocalizedString("About", bundle: currentLanguageBundle!, value: "About", comment: "About"))
    }

}
