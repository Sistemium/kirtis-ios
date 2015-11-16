//
//  SplitViewController.swift
//  Calculator
//
//  Created by Edgar Jan Vuicik on 19/10/15.
//  Copyright © 2015 Edgar Jan Vuicik. All rights reserved.
//


import UIKit

class SplitViewController: UISplitViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredDisplayMode = .AllVisible
        //minimumPrimaryColumnWidth = CGFloat(0.7)
        //preferredPrimaryColumnWidthFraction = CGFloat(0.7)
        //maximumPrimaryColumnWidth = view.bounds.size.width
    }
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        if (self.view.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.Regular && self.view.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Regular) {
//            ((self.viewControllers[1] as! UINavigationController).visibleViewController! as! KirtisTableViewController).isWidthRegular = true
//        }
//    }
    
}