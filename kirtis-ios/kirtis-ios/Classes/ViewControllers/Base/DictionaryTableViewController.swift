//
//  DictionaryTableViewController.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 09/12/15.
//  Copyright © 2015 Sistemium. All rights reserved.
//

import UIKit

class DictionaryTableViewController: UITableViewController {
    private var groups : [GroupOfAbbreviations] = []
    
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
        cell.textLabel?.text = (groups[indexPath.section].dictionary?.allObjects[indexPath.row] as! Abbreviation).shortForm
        cell.detailTextLabel?.text = (groups[indexPath.section].dictionary?.allObjects[indexPath.row] as! Abbreviation).longForm
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "DICTIONARY".localized
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if groups.count == 0{
            for group in StartupDataSyncService.sharedInstance.groups{
                if group.dictionary?.count > 0 {
                    groups.append(group)
                }
            }
            tableView.reloadData()
        }
    }
    
}