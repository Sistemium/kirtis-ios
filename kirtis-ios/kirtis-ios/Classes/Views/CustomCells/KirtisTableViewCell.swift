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
    var statesData : [String] = [] {
        didSet{
            setStates(statesData)
        }
    }
    
    fileprivate func setStates(_ states:[String]){
        var remainingStates = states.count
        var lineNumber:CGFloat = 0
        let space:CGFloat = 5
        while remainingStates > 0{
            let line = UIView()
            line.translatesAutoresizingMaskIntoConstraints = false
            statesView.addSubview(line)
            let height: CGFloat = 34
            statesView.addConstraint(NSLayoutConstraint(item: line, attribute: .top, relatedBy: .equal, toItem: statesView, attribute: .top, multiplier: 1, constant: lineNumber * (height + space)))
            let center = NSLayoutConstraint(item: line, attribute: .centerX , relatedBy: .equal, toItem: statesView, attribute: .centerX, multiplier: 1, constant: 0)
            statesView.addConstraint(center)
            statesView.addConstraint(NSLayoutConstraint(item: line, attribute: .height , relatedBy: .equal, toItem:
                nil, attribute: .notAnAttribute, multiplier: 1, constant: height ))
            statesView.addConstraint(NSLayoutConstraint(item: line, attribute: .width , relatedBy: .equal, toItem:
                nil, attribute: .notAnAttribute, multiplier: 1, constant: 0 ))
            statesView.layoutSubviews()
            let rez = setStates(Array(states[states.count -  remainingStates ... states.count - 1]), view: statesView)
            center.constant -= CGFloat(rez.width / 2)
            statesView.layoutSubviews()
            remainingStates -= rez.usedStates
            lineNumber += 1
        }
        let filterResults = statesView.constraints.filter { $0.identifier == "height" }
        filterResults[0].constant = lineNumber * (34 + space)
    }
    
    fileprivate func setStates(_ states:[String],view:UIView) -> (usedStates:Int,width:Int){
        var width = 0
        var usedStates = 0
        for state in states{
            let label = UILabel()
            let previousElement = view.subviews.last
            let space = 10
            let padding = 20
            label.text = state
            label.font = UIFont.systemFont(ofSize: 17.0)
            label.numberOfLines = 0;
            label.backgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
            label.layer.cornerRadius = 17
            label.clipsToBounds = true
            label.textAlignment = NSTextAlignment.center
            label.translatesAutoresizingMaskIntoConstraints = false
            let text = label.text! as NSString
            let size = text.size(withAttributes: [NSAttributedString.Key.font:label.font])
            width += Int(size.width) + space + padding
            if width > Int(UIScreen.main.bounds.width) && usedStates > 0 {
                return (usedStates,width - (Int(size.width) + space + padding))
            }
            view.addSubview(label)
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: previousElement, attribute: .trailing, multiplier: 1, constant: CGFloat(space)))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY , relatedBy: .equal, toItem:
                previousElement, attribute: .centerY, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .height , relatedBy: .equal, toItem:
                previousElement, attribute: .height, multiplier: 1, constant: 0 ))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .width , relatedBy: .equal, toItem:
                nil , attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: size.width + CGFloat(padding)))
            usedStates += 1
        }
        return (usedStates,width)
    }
    
    //MARK: Gesture recognizer
    
    @objc func handlePress(_ gestureReconizer: UITapGestureRecognizer){
        switch gestureReconizer.state{
        case .ended:
            if word.frame.contains(gestureReconizer.location(in: self)){
                becomeFirstResponder()
                let menu = UIMenuController.shared
                let copyItem = UIMenuItem(title: "COPY".localized, action: #selector(KirtisTableViewCell.copyText))
                menu.menuItems = [copyItem]
                menu.setTargetRect(CGRect(x: gestureReconizer.location(in: self).x - 25, y: gestureReconizer.location(in: self).y, width: 50, height: 50), in: self)
                menu.setMenuVisible(true, animated: true)
                return
            }
            for state in statesView.subviews {
                if state.frame.contains(gestureReconizer.location(in: state.superview)){
                    becomeFirstResponder()
                    let menu = UIMenuController.shared
                    var title = "Unknown"
                    for t in StartupDataSyncService.sharedInstance.dictionary{
                        if (state as! UILabel).text == t.shortForm{
                            title = t.group!.name! + ": " + t.longForm!
                            break
                        }
                    }
                    if title == "Unknown"{
                        Answers.logContentView(withName: "Unknown word atribute",
                            contentType: "Events",
                            contentId: "unk-atrib",
                            customAttributes: [
                                "unknownText": title
                            ]
                        )
                    }
                    let item = UIMenuItem(title: title, action: #selector(KirtisTableViewCell.doNothing))
                    menu.menuItems = [item]
                    menu.setTargetRect(CGRect(x: gestureReconizer.location(in: self).x - 25, y: gestureReconizer.location(in: self).y, width: 50, height: 50), in: self)
                    menu.setMenuVisible(true, animated: true)
                    return
                }
            }
            if part.frame.contains(gestureReconizer.location(in: self)){
                becomeFirstResponder()
                let menu = UIMenuController.shared
                var title = "Unknown"
                for t in StartupDataSyncService.sharedInstance.dictionary{
                    if String(part.text![part.text!.index(part.text!.startIndex, offsetBy: 2)...part.text!.index(part.text!.endIndex, offsetBy: -2)]) == t.shortForm{
                        title = t.group!.name! + ": " + t.longForm!
                        break
                    }
                }
                let item = UIMenuItem(title: title, action: #selector(KirtisTableViewCell.doNothing))
                menu.menuItems = [item]
                menu.setTargetRect(CGRect(x: gestureReconizer.location(in: self).x - 25, y: gestureReconizer.location(in: self).y, width: 50, height: 50), in: self)
                menu.setMenuVisible(true, animated: true)
                return
            }
            UIMenuController.shared.setMenuVisible(false, animated: true)
        default:
            break
        }
    }
    
    @objc fileprivate func doNothing(){
    }
    
    @objc fileprivate func copyText() {
        UIPasteboard.general.string = word.text
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
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
        addGestureRecognizer(press)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        statesView.subviews.forEach { $0.removeFromSuperview() }
    }
}
