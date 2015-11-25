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
    var textToSearch:String? //i dont want to lose current search (opening history destroys KirtisTableView)
    
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
        performSegueWithIdentifier("search", sender: textToSearch ?? "")
    }
    
    private var words: [NSManagedObject]{
        get{
            var w = [NSManagedObject]()
            let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            
            let fetchRequest = NSFetchRequest(entityName: "RecentSearches")
            
            do {
                let results =
                try managedContext.executeFetchRequest(fetchRequest)
                w = results as! [NSManagedObject]
                return w
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            return w
        }
    }
    
    var recentSearches : [String] {
        get{
            var rezult = [String]()
            for word in words{
                rezult.append(word.valueForKey("word") as! String)
            }
            return rezult
        }
        set{
            let managedContext =
            (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            
            let fetchRequest = NSFetchRequest()
            fetchRequest.entity = NSEntityDescription.entityForName("RecentSearches", inManagedObjectContext: managedContext)
            fetchRequest.includesPropertyValues = false
            do {
                if let results = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                    for result in results {
                        managedContext.deleteObject(result)
                    }
                    
                    try managedContext.save()
                }
            } catch {
                print("failed to clear core data")
            }
            
            for searchedWord in newValue{
                let entity =  NSEntityDescription.entityForName("RecentSearches",
                    inManagedObjectContext:managedContext)
                
                let word = NSManagedObject(entity: entity!,
                    insertIntoManagedObjectContext: managedContext)
                word.setValue(searchedWord, forKey: "word")
            }
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
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
        if (sender as! String) != "" {
            destination.textToSearch = (sender as! String)
        }
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
