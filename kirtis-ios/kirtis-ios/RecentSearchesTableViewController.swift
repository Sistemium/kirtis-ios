//
//  RecentSearchesTableViewController.swift
//  Smashtag
//
//  Created by Edgar Jan Vuicik on 01/11/15.
//  Copyright © 2015 Stanford University. All rights reserved.
//

import UIKit

class RecentSearchesTableViewController: UITableViewController {
    
    @IBOutlet var close: UIBarButtonItem!
    
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
        performSegueWithIdentifier("search", sender: "")
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
        if !splitViewController!.collapsed{
            navigationItem.rightBarButtonItems = []
        }else{
            navigationItem.rightBarButtonItems = [close]
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("search", sender: recentSearches[indexPath.item])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = (segue.destinationViewController as! UINavigationController).visibleViewController as! KirtisTableViewController
        destination.navigationItem.setHidesBackButton(true, animated: false)
        destination.textToSearch = (sender as! String)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            var recent = recentSearches
            recent.removeAtIndex(indexPath.row)
            recentSearches = recent
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    @IBAction func goToHistory(segue:UIStoryboardSegue){
    }

}
