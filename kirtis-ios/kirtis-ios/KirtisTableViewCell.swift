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
    @IBOutlet weak var additionalSizeForStates: UIView!
    private let maxFirstLineStates = 3
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    var statesData : [String] = [] {
        didSet{
            var primaryStates = statesData
            var secondaryStates: Array<String> = []
            if primaryStates.count>maxFirstLineStates{
                primaryStates = Array(statesData[0...maxFirstLineStates-1])
                secondaryStates = Array(statesData.suffixFrom(maxFirstLineStates))
            }
            
            setStates(primaryStates, view: states)
            if secondaryStates.count>0{
                setStates(secondaryStates,view: additionalSizeForStates)
            }
        }
    }
    
    private func setStates(states:Array<String>,view:UIView){
        var width = 0
        for state in states{
            let label = UILabel()
            let previousElement = view.subviews.last
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
            view.addSubview(label)
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .Leading, relatedBy: .Equal, toItem: previousElement, attribute: .Trailing, multiplier: 1, constant: CGFloat(space)))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterY , relatedBy: .Equal, toItem:
                previousElement, attribute: .CenterY, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .Height , relatedBy: .Equal, toItem:
                previousElement, attribute: .Height, multiplier: 1, constant: 0 ))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .Width , relatedBy: .Equal, toItem:
                nil , attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: size.width + CGFloat(padding)))
            width += Int(size.width) + space + padding
        }
        view.constraints[0].constant = CGFloat(width)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let press = UITapGestureRecognizer(target: self, action: "handlePress:")
        press.delegate = self
        self.addGestureRecognizer(press)
    }
    
    func handlePress(gestureReconizer: UITapGestureRecognizer){
        switch gestureReconizer.state{
        case .Ended:
            if word.frame.contains(gestureReconizer.locationInView(self)){
                becomeFirstResponder()
                let menu = UIMenuController.sharedMenuController()
                let copyItem = UIMenuItem(title: "Copy", action: Selector("copyText"))
                menu.menuItems = [copyItem]
                menu.setTargetRect(CGRectMake(gestureReconizer.locationInView(self).x - 25, gestureReconizer.locationInView(self).y, 50, 50), inView: self)
                menu.setMenuVisible(true, animated: true)            }
            for state in states.subviews + additionalSizeForStates.subviews {
                if state.frame.contains(gestureReconizer.locationInView(state.superview)){
                    becomeFirstResponder()
                    let menu = UIMenuController.sharedMenuController()
                    var title = "Unknown"
                    for t in appDelegate.dictionary!{
                        //print("\((state as! UILabel).text) \((state as! UILabel).text == t.key ? "" : "" ) \(t.key)");
                        if (state as! UILabel).text == t.key{
                            title = t.group!.name! + ": " + t.value!
                            break
                        }
                    }
                    let item = UIMenuItem(title: title, action: Selector("copyText"))
                    menu.menuItems = [item]
                    menu.setTargetRect(CGRectMake(gestureReconizer.locationInView(self).x - 25, gestureReconizer.locationInView(self).y, 50, 50), inView: self)
                    menu.setMenuVisible(true, animated: true)
                }
            }
            if part.frame.contains(gestureReconizer.locationInView(self)){
                becomeFirstResponder()
                let menu = UIMenuController.sharedMenuController()
                var title = "Unknown"
                for t in appDelegate.dictionary!{
                    if part.text!.substringWithRange(part.text!.startIndex.advancedBy(2)...part.text!.endIndex.advancedBy(-2)) == t.key{
                        title = t.value!
                        break
                    }
                }
                let item = UIMenuItem(title: title, action: Selector("copyText"))
                menu.menuItems = [item]
                menu.setTargetRect(CGRectMake(gestureReconizer.locationInView(self).x - 25, gestureReconizer.locationInView(self).y, 50, 50), inView: self)
                menu.setMenuVisible(true, animated: true)
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
        if additionalSizeForStates.subviews.count > 1{
            for sub in additionalSizeForStates.subviews[1...additionalSizeForStates.subviews.count-1]{
                sub.removeFromSuperview()
            }
        }
    }
}
