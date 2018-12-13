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
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
        viewControllers?[0].tabBarItem.title = "ACCENTUATION".localized
        viewControllers?[1].tabBarItem.title = "SETTINGS".localized
        viewControllers?[2].tabBarItem.title = "DICTIONARY".localized
        viewControllers?[3].tabBarItem.title = "ABOUT".localized
        if FeedbackService.sharedInstance.needsRateApp(){
            viewControllers?[3].tabBarItem.badgeValue = "1"
        }
    }

}
