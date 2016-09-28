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
            ccl.setTitle("CCL".localized, for: UIControlState())
        }
    }
    
    @IBOutlet weak var aboutText: UILabel!{
        didSet{
            let paragraphStyles = NSMutableParagraphStyle()
            paragraphStyles.alignment = .justified
            paragraphStyles.firstLineHeadIndent = 10.0
            let attributes = [NSParagraphStyleAttributeName: paragraphStyles]
            let attributedString = NSAttributedString(string: "ABOUT_TEXT".localized, attributes: attributes)
            aboutText.attributedText = attributedString
        }
    }
    
    @IBOutlet weak var version: UILabel!{
        didSet{
            let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
            let version = nsObject as! String
            self.version.text! = "VERSION".localized + version
        }
    }
    
    @IBOutlet weak var sourceCode: UIButton!{
        didSet{
            sourceCode.setTitle("CODE".localized, for: UIControlState())
        }
    }
    
    @IBOutlet weak var rateUsButton: UIButton!{
        didSet{
            rateUsButton.setTitle("RATE US".localized, for: UIControlState())
        }
    }
    
    
    override func viewDidLoad() {
        title = "ABOUT".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if tabBarController?.viewControllers![3].tabBarItem.badgeValue == "1"{
            tabBarController?.viewControllers![3].tabBarItem.badgeValue = nil
            FeedbackService.sharedInstance.rateAppFromViewController(self)
        }
    }

    @IBAction func linkToSistemium() {
        UIApplication.shared.openURL(URL(string : Constants.sistemiumUrl)!)
    }
    
    @IBAction func linkToCCL() {
        UIApplication.shared.openURL(URL(string : Constants.cclUrl)!)
    }

    
    @IBAction func linkToIcons8() {
        UIApplication.shared.openURL(URL(string : Constants.icons8Url)!)
    }
    
    @IBAction func linkToSource() {
        UIApplication.shared.openURL(URL(string : Constants.sourceUrl)!)
    }
    
    @IBAction func linkToKirtis() {
        UIApplication.shared.openURL(URL(string : Constants.kirtisUrl)!)
    }
    @IBAction func rateUs() {
        FeedbackService.sharedInstance.rateApp()
    }
}
