//
//  SettingsTableViewController.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 21/03/16.
//  Copyright © 2016 Sistemium. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    private var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var staticCell: UITableViewCell!{
        didSet{
            staticCell.textLabel?.text = "LANGUAGE".localized(appDelegate.userLanguage)
            switch appDelegate.userLanguage{
            case "en":
                staticCell.detailTextLabel?.text = "English"
            case "ru":
                staticCell.detailTextLabel?.text = "Русский"
            case "lt":
                staticCell.detailTextLabel?.text = "Lietuvių"
            default:
                break
            }
            self.title = "SETTINGS".localized(appDelegate.userLanguage)
        }
    }
}
