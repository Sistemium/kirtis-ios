//
//  SplitViewController.swift
//  Calculator
//
//  Created by Edgar Jan Vuicik on 19/10/15.
//  Copyright © 2015 Edgar Jan Vuicik. All rights reserved.
//


import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    // Without this detail view is primary view, I need master to be primary
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool{
        return true
    }
    
}