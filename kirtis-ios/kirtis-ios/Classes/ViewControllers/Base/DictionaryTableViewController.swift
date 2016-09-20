//
//  DictionaryTableViewController.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 09/12/15.
//  Copyright © 2015 Sistemium. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class DictionaryTableViewController: UITableViewController {
    fileprivate var groups : [GroupOfAbbreviations] = []
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].dictionary!.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groups[section].name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "dictionary", for: indexPath)
        cell.textLabel?.text = (groups[(indexPath as NSIndexPath).section].dictionary?.allObjects[(indexPath as NSIndexPath).row] as! Abbreviation).shortForm
        cell.detailTextLabel?.text = (groups[(indexPath as NSIndexPath).section].dictionary?.allObjects[(indexPath as NSIndexPath).row] as! Abbreviation).longForm
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DICTIONARY".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
