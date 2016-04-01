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
    private var height : NSLayoutConstraint!
    
    var textField : UITextField!{
        didSet{
            textField.spellCheckingType = .No
            textField.autocorrectionType = .No
            textField.clearButtonMode = .Always
            self.addSubview(textField)
            textField.borderStyle = .RoundedRect
            textField.translatesAutoresizingMaskIntoConstraints = false
            self.addConstraint(NSLayoutConstraint(item: textField, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: textField, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: textField, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: textField, attribute: .Bottom, relatedBy: .Equal, toItem: suggestionTableView, attribute: .Top, multiplier: 1, constant: 0))
        }
    }
    
    var suggestionTableView : UITableView!{
        didSet{
            suggestionTableView.contentInset = UIEdgeInsetsMake(0, -15, 0, 0)
            suggestionTableView.delegate = self
            suggestionTableView.dataSource = self
            suggestionTableView.estimatedRowHeight = 20
            suggestionTableView.rowHeight = UITableViewAutomaticDimension
            for constraint in self.constraints {
                self.removeConstraint(constraint)
            }
            self.addSubview(suggestionTableView)
            suggestionTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "seggestionCell")
            suggestionTableView.translatesAutoresizingMaskIntoConstraints = false
            self.addConstraint(NSLayoutConstraint(item: suggestionTableView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 5))
            self.addConstraint(NSLayoutConstraint(item: suggestionTableView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: suggestionTableView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
            height = NSLayoutConstraint(item: suggestionTableView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0)
            self.addConstraint(height)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customInit()
        textField.addTarget(self, action: #selector(AutocompleteTextField.editingChange), forControlEvents: .EditingChanged)
        textField.addTarget(self, action: #selector(AutocompleteTextField.editingEnd), forControlEvents: .EditingDidEnd)
        textField.addTarget(self, action: #selector(AutocompleteTextField.editingStart), forControlEvents: .EditingDidBegin)
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
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.didSelectWord(suggestions[indexPath.row])
        self.height.constant = 0
        delegate?.didHideSuggestions()
    }
    
    //MARK: Selectors
    
    @objc private func editingStart(){
        if textField.text != "" {
            suggestions = dataSource?.getSuggestions(textField.text!) ?? []
            self.height.constant = suggestions.count > 2 ? 140 : suggestions.count > 1 ? 95 : suggestions.count > 0 ? 50 : 16
            delegate?.didShowSuggestions()
        }else{
            self.height.constant = 0
            delegate?.didHideSuggestions()
        }
    }
    
    @objc private func editingChange(){
        if textField.text != "" {
            suggestions = dataSource?.getSuggestions(textField.text!) ?? []
            self.height.constant = suggestions.count > 2 ? 140 : suggestions.count > 1 ? 95 : suggestions.count > 0 ? 50 : 16
            delegate?.didShowSuggestions()
        }
        else{
            self.height.constant = 0
            delegate?.didHideSuggestions()
        }
    }
    
    @objc private func editingEnd(){
        self.height.constant = 0
        delegate?.didHideSuggestions()
    }
    
}