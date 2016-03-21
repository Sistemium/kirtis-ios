//
//  DictionaryTableViewController.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 09/12/15.
//  Copyright © 2015 Sistemium. All rights reserved.
//

import UIKit

class DictionaryTableViewController: UITableViewController {
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    private var groups : [Group] = []
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        for group in appDelegate.groups{
            if group.dictionary?.count > 0 {
                groups.append(group)
            }
        }
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return groups.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].dictionary!.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groups[section].name
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("dictionary", forIndexPath: indexPath)
        cell.textLabel?.text = groups[indexPath.section].dictionary?.allObjects[indexPath.row].key
        cell.detailTextLabel?.text = groups[indexPath.section].dictionary?.allObjects[indexPath.row].value
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "DICTIONARY".localized(appDelegate.userLanguage)
    }
    
}