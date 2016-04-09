//
//  SettingsTableViewController.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 21/03/16.
//  Copyright © 2016 Sistemium. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var languageCell: UITableViewCell!{
        didSet{
            languageCell.textLabel?.text = "LANGUAGE".localized
            switch LocalizationService.sharedInstance.userLanguage{
            case "en":
                languageCell.detailTextLabel?.text = "English"
            case "ru":
                languageCell.detailTextLabel?.text = "Русский"
            case "lt":
                languageCell.detailTextLabel?.text = "Lietuvių"
            default:
                break
            }
            self.title = "SETTINGS".localized
        }
    }
    
    @IBOutlet weak var autocompleteLabel: UILabel!{
        didSet{
            autocompleteLabel.text = "AUTOCOMPLETE".localized
        }
    }
    
    @IBOutlet weak var autocompleteSwitcher: UISwitch!{
        didSet{
            autocompleteSwitcher.on = NSUserDefaults.standardUserDefaults().objectForKey("autocomplete") as? Bool ?? true
        }
    }
    
    
    @IBAction func autocompleteSwitch(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setObject(sender.on, forKey: "autocomplete")
    }
    
    
}
