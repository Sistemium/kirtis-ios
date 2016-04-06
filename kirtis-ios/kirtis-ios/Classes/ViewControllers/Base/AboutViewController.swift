//
//  AboutViewController.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 30/11/15.
//  Copyright © 2015 Sistemium. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var ccl: UIButton!{
        didSet{
            ccl.setTitle("CCL".localized, forState: .Normal)
        }
    }
    
    @IBOutlet weak var aboutText: UILabel!{
        didSet{
            let paragraphStyles = NSMutableParagraphStyle()
            paragraphStyles.alignment = .Justified
            paragraphStyles.firstLineHeadIndent = 10.0
            let attributes = [NSParagraphStyleAttributeName: paragraphStyles]
            let attributedString = NSAttributedString(string: "ABOUT_TEXT".localized, attributes: attributes)
            aboutText.attributedText = attributedString
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
    
    @IBOutlet weak var likeButton: UIView!{
        didSet{
            let like = FBSDKLikeControl()
            like.objectID = Constants.facebookURL
            likeButton.addSubview(like)
            like.center = like.superview!.convertPoint(like.superview!.center, fromView: like.superview!.superview)
            like.likeControlHorizontalAlignment = .Center
        }
    }
    
    override func viewDidLoad() {
        self.title = "ABOUT".localized
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.tabBarController?.viewControllers![3].tabBarItem.badgeValue == "1"{
            self.tabBarController?.viewControllers![3].tabBarItem.badgeValue = nil
            FeedbackService.sharedInstance.rateAppFromViewController(self)
        }
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
