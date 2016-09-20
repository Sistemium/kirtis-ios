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
        preferredDisplayMode = .allVisible
        //use this to config split size
        minimumPrimaryColumnWidth = CGFloat(0.25)
        preferredPrimaryColumnWidthFraction = CGFloat(0.25)
        maximumPrimaryColumnWidth = view.bounds.size.width
    }
    
}
