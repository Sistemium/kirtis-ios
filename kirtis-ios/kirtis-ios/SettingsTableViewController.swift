//
//  SettingsTableViewController.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 22/11/15.
//  Copyright © 2015 Edgar Jan Vuicik. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet var lithuanianCell: UITableViewCell!
    @IBOutlet var russianCell: UITableViewCell!
    @IBOutlet var englishCell: UITableViewCell!
    @IBOutlet var doneButton: UIBarButtonItem!
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var language: String? {
        get{
            return defaults.objectForKey("Language") as? String ?? nil
        }
        set{
            defaults.setObject(newValue, forKey: "Language")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItems = []

    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = UITableViewCell()
            switch indexPath.row{
            case 1:
                cell = englishCell
            case 2:
                cell = russianCell
            case 3:
                cell = lithuanianCell
            default:
                break;
        }
        clearCheckMarks()
        cell.editingAccessoryType = .Checkmark
        //language = cell.detailTextLabel
    }
    
    private func clearCheckMarks(){
        lithuanianCell.accessoryType = .None
        russianCell.accessoryType = .None
        englishCell.accessoryType = .None
    }
}
