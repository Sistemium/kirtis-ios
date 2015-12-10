//
//  KirtisTableViewCell.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 12/11/15.
//  Copyright © 2015 Edgar Jan Vuicik. All rights reserved.
//

import UIKit
import Crashlytics

class KirtisTableViewCell: UITableViewCell {

    @IBOutlet weak var word: UILabel!
    @IBOutlet weak var part: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var states: UIView!
    //var controller : UITableViewController?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var statesData : [String] = [] {
        didSet{
            var width = 0
            for state in statesData{
                let label = UILabel()
                let previousElement = states.subviews.last
                let space = 10
                let padding = 20
                label.text = state
                label.font = UIFont.systemFontOfSize(17.0)
                label.numberOfLines = 0;
                label.backgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
                label.layer.cornerRadius = 17
                label.clipsToBounds = true
                label.textAlignment = NSTextAlignment.Center
                label.translatesAutoresizingMaskIntoConstraints = false
                let text = label.text! as NSString
                let size = text.sizeWithAttributes([NSFontAttributeName:label.font])
                states.addSubview(label)
                states.addConstraint(NSLayoutConstraint(item: label, attribute: .Leading, relatedBy: .Equal, toItem: previousElement, attribute: .Trailing, multiplier: 1, constant: CGFloat(space)))
                states.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterY , relatedBy: .Equal, toItem:
                    previousElement, attribute: .CenterY, multiplier: 1, constant: 0))
                states.addConstraint(NSLayoutConstraint(item: label, attribute: .Height , relatedBy: .Equal, toItem:
                    previousElement, attribute: .Height, multiplier: 1, constant: 0 ))
                states.addConstraint(NSLayoutConstraint(item: label, attribute: .Width , relatedBy: .Equal, toItem:
                    nil , attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: size.width + CGFloat(padding)))
                width += Int(size.width) + space + padding
            }
            states.constraints[0].constant = CGFloat(width)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let longPress = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPress.minimumPressDuration = 0.3
        longPress.delaysTouchesBegan = true
        longPress.delegate = self
        self.addGestureRecognizer(longPress)
    }
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer){
        switch gestureReconizer.state{
        case .Began:
            if word.frame.contains(gestureReconizer.locationInView(self)){
                becomeFirstResponder()
                let menu = UIMenuController.sharedMenuController()
                let copyItem = UIMenuItem(title: "Copy", action: Selector("copyText"))
                menu.menuItems = [copyItem]
                menu.setTargetRect(CGRectMake(gestureReconizer.locationInView(self).x - 25, gestureReconizer.locationInView(self).y, 50, 50), inView: self)
                menu.setMenuVisible(true, animated: true)            }
            for state in states.subviews{
                if state.frame.contains(gestureReconizer.locationInView(state.superview)){
//                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//                    let currentLanguageBundle = NSBundle(path:NSBundle.mainBundle().pathForResource(appDelegate.userLanguage , ofType:"lproj")!)
//                    let storyboard = UIStoryboard(name: "Main", bundle: currentLanguageBundle)
//        
//                    let fromRect:CGRect = state.frame
//        
//                    let popoverVC = storyboard.instantiateViewControllerWithIdentifier("popover")
//                    popoverVC.modalPresentationStyle = .Popover
//                    controller!.presentViewController(popoverVC, animated: true, completion: nil)
//                    let popoverController = popoverVC.popoverPresentationController
//                    popoverController!.sourceView = self
//                    popoverController!.sourceRect = fromRect
//                    popoverController!.permittedArrowDirections = .Any
                    becomeFirstResponder()
                    let menu = UIMenuController.sharedMenuController()
                    var title = "UNKNOWN"
                    for t in appDelegate.dictionary!{
                        if (state as! UILabel).text == t.key{
                            title = t.value!
                        }
                    }
                    let item = UIMenuItem(title: title, action: Selector("copyText"))
                    menu.menuItems = [item]
                    menu.setTargetRect(CGRectMake(gestureReconizer.locationInView(self).x - 25, gestureReconizer.locationInView(self).y, 50, 50), inView: self)
                    menu.setMenuVisible(true, animated: true)
                }
            }
            
        default:
            break
        }
    }
    
    func copyText() {
        UIPasteboard.generalPasteboard().string = word.text
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == Selector("copyText") {
            return true
        }
        return false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if states.subviews.count > 1{
            for sub in states.subviews[1...states.subviews.count-1]{
                sub.removeFromSuperview()
            }
        }
    }
}
