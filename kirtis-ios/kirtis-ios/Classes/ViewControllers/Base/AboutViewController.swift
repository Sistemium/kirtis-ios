//
//  AboutViewController.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 30/11/15.
//  Copyright © 2015 Sistemium. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var ccl: UIButton!{
        didSet{
            ccl.setTitle("CCL".localized, forState: .Normal)
        }
    }
    
    @IBOutlet weak var aboutText: UILabel!{
        didSet{
            aboutText.text = "ABOUT_TEXT".localized
        }
    }
    
    @IBOutlet weak var version: UILabel!{
        didSet{
            let nsObject: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
            let version = nsObject as! String
            self.version.text! = "VERSION".localized + version
        }
    }
    
    @IBOutlet weak var sourceCode: UIButton!{
        didSet{
            sourceCode.setTitle("CODE".localized, forState: .Normal)
        }
    }
    
    override func viewDidLoad() {
        self.title = "ABOUT".localized
    }

    @IBAction func linkToSistemium() {
        UIApplication.sharedApplication().openURL(NSURL(string : Constants.sistemiumUrl)!)
    }
    
    @IBAction func linkToCCL() {
        UIApplication.sharedApplication().openURL(NSURL(string : Constants.cclUrl)!)
    }

    
    @IBAction func linkToIcons8() {
        UIApplication.sharedApplication().openURL(NSURL(string : Constants.icons8Url)!)
    }
    
    @IBAction func linkToSource() {
        UIApplication.sharedApplication().openURL(NSURL(string : Constants.sourceUrl)!)
    }
    
    @IBAction func linkToKirtis() {
        UIApplication.sharedApplication().openURL(NSURL(string : Constants.kirtisUrl)!)
    }
}
