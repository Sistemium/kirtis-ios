//
//  AboutViewController.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 30/11/15.
//  Copyright © 2015 Sistemium. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    
    @IBOutlet weak var Version: UILabel!
    
    override func viewDidLoad() {
        let nsObject: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
        let version = nsObject as! String
        Version.text! += version
    }

    @IBAction func linkToSistemium() {
        UIApplication.sharedApplication().openURL(NSURL(string : Url.sistemium)!)
    }
    
    @IBAction func linkToKirstis() {
        UIApplication.sharedApplication().openURL(NSURL(string : Url.kirtis)!)
    }
    
    @IBAction func linkToCCL() {
        UIApplication.sharedApplication().openURL(NSURL(string : Url.CCl)!)
    }

    
    @IBAction func linkToIcons8() {
        UIApplication.sharedApplication().openURL(NSURL(string : Url.icons8)!)
    }
    
    @IBAction func linkToSource() {
        UIApplication.sharedApplication().openURL(NSURL(string : Url.source)!)
    }
    
    
    private struct Url {
        static let sistemium = "https://sistemium.com"
        static let kirtis = "http://kirtis.info"
        static let CCl = "http://donelaitis.vdu.lt/index_en.php"
        static let icons8 = "https://icons8.com"
        static let source = "https://github.com/Sistemium/kirtis-ios"
    }
}
