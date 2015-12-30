//
//  RecentSearchesTableViewController.swift
//  Smashtag
//
//  Created by Edgar Jan Vuicik on 01/11/15.
//  Copyright © 2015 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class RecentSearchesTableViewController: UITableViewController {
    
    @IBOutlet var close: UIBarButtonItem!
    var textToSearch:String? //I dont want to lose current search (opening history destroys KirtisTableView)
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "shouldButtonAppear", name: UIDeviceOrientationDidChangeNotification, object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @IBAction func close(sender: UIBarButtonItem) {
        performSegueWithIdentifier("search", sender: textToSearch)
    }
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var recentSearches : [String] {
        get{
            return defaults.objectForKey("RecentSearches") as? [String] ?? []
        }
        set{
            defaults.setObject(newValue, forKey: "RecentSearches")
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        cell.textLabel?.text = recentSearches[indexPath.row]
        return cell
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        shouldButtonAppear()
    }
    
    func shouldButtonAppear(){
        if splitViewController?.collapsed ?? false{
            navigationItem.rightBarButtonItems = [close]
        }else{
            navigationItem.rightBarButtonItems = []
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("search", sender: recentSearches[indexPath.item])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = (segue.destinationViewController as! UINavigationController).visibleViewController as! KirtisTableViewController
        destination.navigationItem.setHidesBackButton(true, animated: false)
        if sender != nil{
            destination.textToSearch = (sender as! String)
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            if textToSearch == recentSearches[indexPath.row]{
                textToSearch = nil
            }
            var recent = recentSearches
            recent.removeAtIndex(indexPath.row)
            recentSearches = recent
            tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  cell = UITableViewCell()
        
        if recentSearches.count == 0 {
            cell.textLabel?.textAlignment = .Center
            let currentLanguageBundle = NSBundle(path:NSBundle.mainBundle().pathForResource(self.appDelegate.userLanguage , ofType:"lproj")!)
            let message = NSLocalizedString("History is empty", bundle: currentLanguageBundle!, value: "History is empty", comment: "History is empty")
            cell.textLabel?.text = message
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if recentSearches.count>0 {
            return 0
        }
        return 50
    }
    
    @IBAction func goToHistory(segue:UIStoryboardSegue){
    }

}
