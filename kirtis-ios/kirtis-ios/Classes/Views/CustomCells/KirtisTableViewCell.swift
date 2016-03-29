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

    @IBOutlet weak var statesView: UIView!
    @IBOutlet weak var word: UILabel!
    @IBOutlet weak var part: UILabel!
    @IBOutlet weak var message: UILabel!
    let maxStatesInLine = 4
    var statesData : [String] = [] {
        didSet{
            setStates(statesData)
        }
    }
    
    private func setStates(states:[String]){
        var remainingStates = states.count
        if remainingStates > 8 {
            Answers.logContentViewWithName("Interesting words",
                contentType: "Events",
                contentId: "int-words",
                customAttributes: [
                    "intText": word.text!
                ]
            )
        }
        var lineNumber:CGFloat = 0
        let space:CGFloat = 5
        while remainingStates > 0{
            let line = UIView()
            line.translatesAutoresizingMaskIntoConstraints = false
            statesView.addSubview(line)
            let height: CGFloat = 34
            statesView.addConstraint(NSLayoutConstraint(item: line, attribute: .Top, relatedBy: .Equal, toItem: statesView, attribute: .Top, multiplier: 1, constant: lineNumber * (height + space)))
            let center = NSLayoutConstraint(item: line, attribute: .CenterX , relatedBy: .Equal, toItem: statesView, attribute: .CenterX, multiplier: 1, constant: 0)
            statesView.addConstraint(center)
            statesView.addConstraint(NSLayoutConstraint(item: line, attribute: .Height , relatedBy: .Equal, toItem:
                nil, attribute: .NotAnAttribute, multiplier: 1, constant: height ))
            statesView.addConstraint(NSLayoutConstraint(item: line, attribute: .Width , relatedBy: .Equal, toItem:
                nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0 ))
            statesView.layoutSubviews()
            let rez = setStates(Array(states[states.count -  remainingStates ... states.count - 1]), view: statesView)
            if rez.width > Int(UIScreen.mainScreen().bounds.width) {
                Answers.logContentViewWithName("Interesting words",
                    contentType: "Events",
                    contentId: "int-words",
                    customAttributes: [
                        "intText": word.text!
                    ]
                )
            }
            center.constant -= CGFloat(rez.width / 2)
            statesView.layoutSubviews()
            remainingStates -= rez.usedStates
            lineNumber++
        }
        let filterResults = statesView.constraints.filter { $0.identifier == "height" }
        filterResults[0].constant = lineNumber * (34 + space)
    }
    
    private func setStates(states:[String],view:UIView) -> (usedStates:Int,width:Int){
        var width = 0
        var usedStates = 0
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
            width += Int(size.width) + space + padding
            view.addSubview(label)
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .Leading, relatedBy: .Equal, toItem: previousElement, attribute: .Trailing, multiplier: 1, constant: CGFloat(space)))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterY , relatedBy: .Equal, toItem:
                previousElement, attribute: .CenterY, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .Height , relatedBy: .Equal, toItem:
                previousElement, attribute: .Height, multiplier: 1, constant: 0 ))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .Width , relatedBy: .Equal, toItem:
                nil , attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: size.width + CGFloat(padding)))
            usedStates += 1
            if usedStates == maxStatesInLine {
                return (usedStates,width)
            }
        }
        return (usedStates,width)
    }
    
    //MARK: Gesture recognizer
    
    func handlePress(gestureReconizer: UITapGestureRecognizer){
        switch gestureReconizer.state{
        case .Ended:
            if word.frame.contains(gestureReconizer.locationInView(self)){
                becomeFirstResponder()
                let menu = UIMenuController.sharedMenuController()
                let copyItem = UIMenuItem(title: "COPY".localized, action: #selector(KirtisTableViewCell.copyText))
                menu.menuItems = [copyItem]
                menu.setTargetRect(CGRectMake(gestureReconizer.locationInView(self).x - 25, gestureReconizer.locationInView(self).y, 50, 50), inView: self)
                menu.setMenuVisible(true, animated: true)
                return
            }
            for state in statesView.subviews {
                if state.frame.contains(gestureReconizer.locationInView(state.superview)){
                    becomeFirstResponder()
                    let menu = UIMenuController.sharedMenuController()
                    var title = "Unknown"
                    for t in StartupDataSyncService.sharedInstance.dictionary{
                        if (state as! UILabel).text == t.shortForm{
                            title = t.group!.name! + ": " + t.longForm!
                            break
                        }
                    }
                    if title == "Unknown"{
                        Answers.logContentViewWithName("Unknown word atribute",
                            contentType: "Events",
                            contentId: "unk-atrib",
                            customAttributes: [
                                "unknownText": title
                            ]
                        )
                    }
                    let item = UIMenuItem(title: title, action: #selector(KirtisTableViewCell.doNothing))
                    menu.menuItems = [item]
                    menu.setTargetRect(CGRectMake(gestureReconizer.locationInView(self).x - 25, gestureReconizer.locationInView(self).y, 50, 50), inView: self)
                    menu.setMenuVisible(true, animated: true)
                    return
                }
            }
            if part.frame.contains(gestureReconizer.locationInView(self)){
                becomeFirstResponder()
                let menu = UIMenuController.sharedMenuController()
                var title = "Unknown"
                for t in StartupDataSyncService.sharedInstance.dictionary{
                    if part.text!.substringWithRange(part.text!.startIndex.advancedBy(2)...part.text!.endIndex.advancedBy(-2)) == t.shortForm{
                        title = t.group!.name! + ": " + t.longForm!
                        break
                    }
                }
                let item = UIMenuItem(title: title, action: #selector(KirtisTableViewCell.doNothing))
                menu.menuItems = [item]
                menu.setTargetRect(CGRectMake(gestureReconizer.locationInView(self).x - 25, gestureReconizer.locationInView(self).y, 50, 50), inView: self)
                menu.setMenuVisible(true, animated: true)
                return
            }
            UIMenuController.sharedMenuController().setMenuVisible(false, animated: true)
        default:
            break
        }
    }
    
    @objc private func doNothing(){
    }
    
    @objc private func copyText() {
        UIPasteboard.generalPasteboard().string = word.text
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(KirtisTableViewCell.copyText) || action == #selector(KirtisTableViewCell.doNothing) {
            return true
        }
        return false
    }
    
    //MARK: Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let press = UITapGestureRecognizer(target: self, action: #selector(KirtisTableViewCell.handlePress(_:)))
        press.delegate = self
        self.addGestureRecognizer(press)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        statesView.subviews.forEach { $0.removeFromSuperview() }
    }
}
