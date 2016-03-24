//
//  TabBarController.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 26/11/15.
//  Copyright © 2015 Sistemium. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func awakeFromNib(){
        super.awakeFromNib()
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(16)]
        self.viewControllers?[0].tabBarItem.title = "ACCENTUATION".localized
        self.viewControllers?[1].tabBarItem.title = "SETTINGS".localized
        self.viewControllers?[2].tabBarItem.title = "DICTIONARY".localized
        self.viewControllers?[3].tabBarItem.title = "ABOUT".localized
    }

}
