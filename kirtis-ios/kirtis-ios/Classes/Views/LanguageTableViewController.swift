//
//  LanguageTableViewController.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 22/11/15.
//  Copyright © 2015 Edgar Jan Vuicik. All rights reserved.
//

import UIKit
import CoreData

class LanguageTableViewController: UITableViewController {
    
    @IBOutlet var lithuanianCell: UITableViewCell!{
        didSet{
            lithuanianCell.detailTextLabel?.text = "LITHUANIAN".localized(appDelegate.userLanguage)
        }
    }
    @IBOutlet var russianCell: UITableViewCell!{
        didSet{
            russianCell.detailTextLabel?.text = "RUSSIAN".localized(appDelegate.userLanguage)
        }
    }
    @IBOutlet var englishCell: UITableViewCell!{
        didSet{
            englishCell.detailTextLabel?.text = "ENGLISH".localized(appDelegate.userLanguage)
        }
    }
    @IBOutlet var doneButton: UIBarButtonItem!{
        didSet{
            doneButton.title = "DONE".localized(appDelegate.userLanguage)
        }
    }
    
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!{
        didSet{
            cancelButton.title = "CANCEL".localized(appDelegate.userLanguage)
        }
    }
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    private var suggestedLanguage : String?
    
    @IBAction func done(sender: UIBarButtonItem) {
        switch suggestedLanguage{
        case "English"?:
            appDelegate.userLanguage = "en"
        case "Русский"?:
            appDelegate.userLanguage = "ru"
        case "Lietuvių"?:
            appDelegate.userLanguage = "lt"
        default:
            break
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItems = []
        switch appDelegate.userLanguage{
            case "en":
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "LANGUAGE".localized(appDelegate.userLanguage)
    }
}
