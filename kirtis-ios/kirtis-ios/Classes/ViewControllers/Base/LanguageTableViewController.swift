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
            lithuanianCell.detailTextLabel?.text = "LITHUANIAN".localized
        }
    }
    @IBOutlet var russianCell: UITableViewCell!{
        didSet{
            russianCell.detailTextLabel?.text = "RUSSIAN".localized
        }
    }
    @IBOutlet var englishCell: UITableViewCell!{
        didSet{
            englishCell.detailTextLabel?.text = "ENGLISH".localized
        }
    }
    @IBOutlet var doneButton: UIBarButtonItem!{
        didSet{
            doneButton.title = "DONE".localized
        }
    }
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!{
        didSet{
            cancelButton.title = "CANCEL".localized
        }
    }

    fileprivate var suggestedLanguage : String?
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        switch suggestedLanguage{
        case "English"?:
            LocalizationService.sharedInstance.userLanguage = "en"
        case "Русский"?:
            LocalizationService.sharedInstance.userLanguage = "ru"
        case "Lietuvių"?:
            LocalizationService.sharedInstance.userLanguage = "lt"
        default:
            break
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func clearCheckMarks(){
        lithuanianCell.accessoryType = .none
        russianCell.accessoryType = .none
        englishCell.accessoryType = .none
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var cell = UITableViewCell()
        switch (indexPath as NSIndexPath).row{
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
        cell.accessoryType = .checkmark
        suggestedLanguage = cell.textLabel?.text
        navigationItem.rightBarButtonItems = [doneButton]
        tableView.reloadData()
    }
    
    //MARK: Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItems = []
        switch LocalizationService.sharedInstance.userLanguage{
        case "en":
            englishCell.accessoryType = .checkmark
        case "ru":
            russianCell.accessoryType = .checkmark
        case "lt":
            lithuanianCell.accessoryType = .checkmark
        default:
            englishCell.accessoryType = .checkmark
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "LANGUAGE".localized
    }
}
