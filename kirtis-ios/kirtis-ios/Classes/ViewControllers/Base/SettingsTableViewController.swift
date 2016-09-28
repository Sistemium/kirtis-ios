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
            title = "SETTINGS".localized
        }
    }
    
    @IBOutlet weak var autocompleteLabel: UILabel!{
        didSet{
            autocompleteLabel.text = "AUTOCOMPLETE".localized
        }
    }
    
    @IBOutlet weak var autocompleteSwitcher: UISwitch!{
        didSet{
            autocompleteSwitcher.isOn = UserDefaults.standard.object(forKey: "autocomplete") as? Bool ?? true
        }
    }
    
    
    @IBAction func autocompleteSwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "autocomplete")
    }
    
    
}
