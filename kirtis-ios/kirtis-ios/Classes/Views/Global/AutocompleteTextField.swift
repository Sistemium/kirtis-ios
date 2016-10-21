//
//  AutocompleteTextField.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 29/03/16.
//  Copyright © 2016 Sistemium. All rights reserved.
//

import UIKit

class AutocompleteTextField: UIView,UITableViewDataSource,UITableViewDelegate {
    
    weak var delegate : AutocompleteTextFieldDelegate?
    weak var dataSource : AutocompleteTextFieldDataSource?
    fileprivate var suggestions = [String](){
        didSet{
            suggestionTableView.reloadData()
        }
    }
    fileprivate(set) var height : NSLayoutConstraint!
    
    var textField : UITextField!{
        didSet{
            textField.spellCheckingType = .no
            textField.autocorrectionType = .no
            textField.clearButtonMode = .always
            addSubview(textField)
            textField.borderStyle = .roundedRect
            textField.translatesAutoresizingMaskIntoConstraints = false
            addConstraint(NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: textField, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: textField, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: textField, attribute: .bottom, relatedBy: .equal, toItem: suggestionTableView, attribute: .top, multiplier: 1, constant: 0))
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
            suggestionTableView.register(UITableViewCell.self, forCellReuseIdentifier: "seggestionCell")
            suggestionTableView.translatesAutoresizingMaskIntoConstraints = false
            addConstraint(NSLayoutConstraint(item: suggestionTableView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 5))
            addConstraint(NSLayoutConstraint(item: suggestionTableView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
            addConstraint(NSLayoutConstraint(item: suggestionTableView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
            height = NSLayoutConstraint(item: suggestionTableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
            addConstraint(height)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
        textField.addTarget(self, action: #selector(AutocompleteTextField.editingChange), for: .editingChanged)
        textField.addTarget(self, action: #selector(AutocompleteTextField.editingEnd), for: .editingDidEnd)
        textField.addTarget(self, action: #selector(AutocompleteTextField.editingChange), for: .editingDidBegin)
    }
    
    fileprivate func customInit(){
        suggestionTableView = UITableView()
        textField = UITextField()
    }
    
    //MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "seggestionCell")!
        cell.textLabel!.text = suggestions[(indexPath as NSIndexPath).row]
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = bgColorView
        cell.textLabel?.highlightedTextColor = UIColor.blue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectWord(suggestions[(indexPath as NSIndexPath).row])
        height.constant = 0
        delegate?.didHideSuggestions()
    }
    
    //MARK: Selectors
    
    @objc fileprivate func editingChange(){
        if textField.text != "" && delegate?.isAutocompleteEnabled() ?? true{
            suggestions = dataSource?.getSuggestions(textField.text!) ?? []
            height.constant = suggestions.count > 3 ? 195 : suggestions.count > 2 ? 140 : suggestions.count > 1 ? 95 : suggestions.count > 0 ? 50 : 0
            if height.constant > 0 {
                delegate?.didShowSuggestions()
                suggestionTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                suggestionTableView.setContentOffset(CGPoint(x: -suggestionTableView.contentInset.left, y: 0), animated:false)
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
    
    @objc fileprivate func editingEnd(){
        if height.constant > 0{
            height.constant = 0
            delegate?.didHideSuggestions()
        }
    }
    
}
