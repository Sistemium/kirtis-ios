//
//  AutocompleteTextField.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 29/03/16.
//  Copyright © 2016 Sistemium. All rights reserved.
//

import UIKit

class AutocompleteTextField: UIView,UITableViewDataSource,UITableViewDelegate {
    
    var delegate : AutocompleteTextFieldDelegate?
    var dataSource : AutocompleteTextFieldDataSource?
    private var suggestions = [String](){
        didSet{
            suggestionTableView.reloadData()
        }
    }
    private(set) var height : NSLayoutConstraint!
    
    var textField : UITextField!{
        didSet{
            textField.spellCheckingType = .No
            textField.autocorrectionType = .No
            textField.clearButtonMode = .Always
            addSubview(textField)
            textField.borderStyle = .RoundedRect
            textField.translatesAutoresizingMaskIntoConstraints = false
            addConstraint(NSLayoutConstraint(item: textField, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: textField, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: textField, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: textField, attribute: .Bottom, relatedBy: .Equal, toItem: suggestionTableView, attribute: .Top, multiplier: 1, constant: 0))
        }
    }
    
    var suggestionTableView : UITableView!{
        didSet{
            suggestionTableView.contentInset = UIEdgeInsetsMake(0, -15, 0, 0)
            suggestionTableView.delegate = self
            suggestionTableView.dataSource = self
            suggestionTableView.estimatedRowHeight = 20
            suggestionTableView.rowHeight = UITableViewAutomaticDimension
            for constraint in constraints {
                removeConstraint(constraint)
            }
            addSubview(suggestionTableView)
            suggestionTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "seggestionCell")
            suggestionTableView.translatesAutoresizingMaskIntoConstraints = false
            addConstraint(NSLayoutConstraint(item: suggestionTableView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 5))
            addConstraint(NSLayoutConstraint(item: suggestionTableView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: suggestionTableView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
            height = NSLayoutConstraint(item: suggestionTableView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0)
            addConstraint(height)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
        textField.addTarget(self, action: #selector(AutocompleteTextField.editingChange), forControlEvents: .EditingChanged)
        textField.addTarget(self, action: #selector(AutocompleteTextField.editingEnd), forControlEvents: .EditingDidEnd)
        textField.addTarget(self, action: #selector(AutocompleteTextField.editingChange), forControlEvents: .EditingDidBegin)
    }
    
    private func customInit(){
        suggestionTableView = UITableView()
        textField = UITextField()
    }
    
    //MARK: TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("seggestionCell")!
        cell.textLabel!.text = suggestions[indexPath.row]
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clearColor()
        cell.selectedBackgroundView = bgColorView
        cell.textLabel?.highlightedTextColor = UIColor.blueColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.didSelectWord(suggestions[indexPath.row])
        height.constant = 0
        delegate?.didHideSuggestions()
    }
    
    //MARK: Selectors
    
    @objc private func editingChange(){
        if textField.text != "" && delegate?.isAutocompleteEnabled() ?? true{
            suggestions = dataSource?.getSuggestions(textField.text!) ?? []
            height.constant = suggestions.count > 3 ? 195 : suggestions.count > 2 ? 140 : suggestions.count > 1 ? 95 : suggestions.count > 0 ? 50 : 0
            if height.constant > 0 {
                delegate?.didShowSuggestions()
                suggestionTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
                suggestionTableView.setContentOffset(CGPointMake(-suggestionTableView.contentInset.left, 0), animated:false)
            }else{
                delegate?.didHideSuggestions()
            }
        }
        else{
            if height.constant > 0{
                height.constant = 0
                delegate?.didHideSuggestions()
            }
        }
    }
    
    @objc private func editingEnd(){
        if height.constant > 0{
            height.constant = 0
            delegate?.didHideSuggestions()
        }
    }
    
}