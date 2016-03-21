//
//  AboutViewController.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 30/11/15.
//  Copyright © 2015 Sistemium. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    @IBOutlet weak var CCL: UIButton!{
        didSet{
            CCL.setTitle("CCL".localized(appDelegate.userLanguage), forState: .Normal)
        }
    }
    
    @IBOutlet weak var aboutText: UILabel!{
        didSet{
            aboutText.text = "ABOUT_TEXT".localized(appDelegate.userLanguage)
        }
    }
    
    @IBOutlet weak var Version: UILabel!{
        didSet{
            let nsObject: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
            let version = nsObject as! String
            Version.text! = "VERSION".localized(appDelegate.userLanguage) + version
        }
    }
    
    @IBOutlet weak var sourceCode: UIButton!{
        didSet{
            sourceCode.setTitle("CODE".localized(appDelegate.userLanguage), forState: .Normal)
        }
    }
    
    override func viewDidLoad() {
        self.title = "ABOUT".localized(appDelegate.userLanguage)
    }

    @IBAction func linkToSistemium() {
        UIApplication.sharedApplication().openURL(NSURL(string : Url.sistemium)!)
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
    
    @IBAction func linkToKirtis() {
        UIApplication.sharedApplication().openURL(NSURL(string : Url.kirtis)!)
    }
    
    
    private struct Url {
        static let sistemium = "https://sistemium.com"
        static let kirtis = "http://kirtis.info"
        static let CCl = "http://donelaitis.vdu.lt/index_en.php"
        static let icons8 = "https://icons8.com"
        static let source = "https://github.com/Sistemium/kirtis-ios"
    }
}
