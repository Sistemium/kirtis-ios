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

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var states: UILabel!
    
    override func layoutSubviews() {
        let longPress = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPress.minimumPressDuration = 0.5
        longPress.delaysTouchesBegan = true
        longPress.delegate = self
        self.addGestureRecognizer(longPress)
    }
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer){
        if title.frame.contains(gestureReconizer.locationInView(self)){
            switch gestureReconizer.state{
            case .Began:
                becomeFirstResponder()
                let menu = UIMenuController.sharedMenuController()
                let copyItem = UIMenuItem(title: "Copy", action: Selector("copyText"))
                menu.menuItems = [copyItem]
                menu.setTargetRect(CGRectMake(gestureReconizer.locationInView(self).x - 25, gestureReconizer.locationInView(self).y, 50, 50), inView: self)
                menu.setMenuVisible(true, animated: true)
            default:
                break
            }
        }
    }
    
    func copyText() {
        UIPasteboard.generalPasteboard().string = title.text
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
}
