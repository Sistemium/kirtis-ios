//
//  SettingsTableViewController.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 22/11/15.
//  Copyright © 2015 Edgar Jan Vuicik. All rights reserved.
//

import UIKit
import CoreData

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet var lithuanianCell: UITableViewCell!
    @IBOutlet var russianCell: UITableViewCell!
    @IBOutlet var englishCell: UITableViewCell!
    @IBOutlet var doneButton: UIBarButtonItem!
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBAction func done(sender: UIBarButtonItem) {
        switch suggestedLanguage{
        case "English"?:
            NSUserDefaults.standardUserDefaults().setObject(["en"], forKey: "AppleLanguages")
            NSUserDefaults.standardUserDefaults().synchronize()
            appDelegate.userLanguage = "Base"
            let bundlePath = NSBundle.mainBundle().pathForResource(appDelegate.userLanguage, ofType: "lproj")
            let bundle = NSBundle(path:bundlePath!)
            let storyBoard = UIStoryboard(name:"Main", bundle:bundle)
            appDelegate.window!.rootViewController = storyBoard.instantiateViewControllerWithIdentifier("root")
        case "Русский"?:
            NSUserDefaults.standardUserDefaults().setObject(["ru"], forKey: "AppleLanguages")
            NSUserDefaults.standardUserDefaults().synchronize()
            appDelegate.userLanguage = "ru"
            let bundlePath = NSBundle.mainBundle().pathForResource(appDelegate.userLanguage, ofType: "lproj")
            let bundle = NSBundle(path:bundlePath!)
            let storyBoard = UIStoryboard(name:"Main", bundle:bundle)
            appDelegate.window!.rootViewController = storyBoard.instantiateViewControllerWithIdentifier("root")
        case "Lietuvių"?:
            NSUserDefaults.standardUserDefaults().setObject(["lt"], forKey: "AppleLanguages")
            NSUserDefaults.standardUserDefaults().synchronize()
            appDelegate.userLanguage = "lt"
            let bundlePath = NSBundle.mainBundle().pathForResource(appDelegate.userLanguage, ofType: "lproj")
            let bundle = NSBundle(path:bundlePath!)
            let storyBoard = UIStoryboard(name:"Main", bundle:bundle)
            appDelegate.window!.rootViewController = storyBoard.instantiateViewControllerWithIdentifier("root")
        default:
        break
        }
        cancel(sender)
    }
    
    private var suggestedLanguage : String?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItems = []
        switch appDelegate.userLanguage{
            case "Base":
            englishCell.accessoryType = .Checkmark
            case "ru":
            russianCell.accessoryType = .Checkmark
            case "lt":
            lithuanianCell.accessoryType = .Checkmark
        default:
            englishCell.accessoryType = .Checkmark
        }
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = UITableViewCell()
            switch indexPath.row{
            case 0:
                cell = englishCell
            case 1:
                cell = russianCell
            case 2:
                cell = lithuanianCell
            default:
                break;
        }
        clearCheckMarks()
        cell.accessoryType = .Checkmark
        suggestedLanguage = cell.textLabel?.text
        navigationItem.rightBarButtonItems = [doneButton]
        tableView.reloadData()
    }
    
    private func clearCheckMarks(){
        lithuanianCell.accessoryType = .None
        russianCell.accessoryType = .None
        englishCell.accessoryType = .None
    }
}
