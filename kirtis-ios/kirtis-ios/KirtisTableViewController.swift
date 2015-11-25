//
//  KirtisTableViewController.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 12/11/15.
//  Copyright © 2015 Edgar Jan Vuicik. All rights reserved.
//

import UIKit
import Crashlytics
import CoreData

class KirtisTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet var history: UIBarButtonItem!
    @IBOutlet var textFieldForWord: UITextField!
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var textToSearch:String?{
        didSet{
            var text = textToSearch!.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "")
            if text.characters.count > 0{
                text = text.substringToIndex(text.startIndex.advancedBy(1)).uppercaseString + text.substringFromIndex(text.startIndex.advancedBy(1)) //uppercase
            }
            textToSearch = text
            Crashlytics.sharedInstance().setObjectValue(textToSearch, forKey: "textToSearch")
        }
    }
    private var accentuations: [Accentuation]?{
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        textFieldForWord.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "shouldButtonAppear", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated:false);
        if let text = textToSearch{
            textFieldForWord.text = text
            search()
        }
        shouldButtonAppear()
    }
    
    func shouldButtonAppear(){
        if splitViewController?.collapsed ?? false{
            navigationItem.rightBarButtonItems = [history]
        }else{
            navigationItem.rightBarButtonItems = []
        }
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        accentuations = nil
        return true
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
            // I need update history immediately, best way to do it here,
            //because viewWillAppear is not called on recentSearches Controller if there was no segue (e.g. Landscape mode)
            ((self.splitViewController?.viewControllers[0] as! UINavigationController).visibleViewController as! UITableViewController).tableView.reloadData()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textToSearch = textField.text
        search()
        return true
    }
    
    private func search(){
        self.accentuations = [Accentuation(message: "loading")]
        let text = textToSearch!
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)){
            if (text == self.textToSearch){
                let accent = self.getAccentuations(text) //what if it fails?
                dispatch_async(dispatch_get_main_queue()){
                    self.accentuations = accent
                    if self.accentuations?.count > 0 {
                        self.appendHistory(text)
                    }
                    else{
                        let currentLanguageBundle = NSBundle(path:NSBundle.mainBundle().pathForResource(self.appDelegate.userLanguage , ofType:"lproj")!)
                        print(self.appDelegate.userLanguage)
                        if text == ""{
                            let message = NSLocalizedString("Nothing was typed", bundle: currentLanguageBundle!, value: "Nothing was typed", comment: "Nothing was typed")
                            self.accentuations = [Accentuation(message: message)]
                        }else{
                            let message = NSLocalizedString("Word is not found", bundle: currentLanguageBundle!, value: "Word is not found", comment: "Word is not found")
                            self.accentuations = [Accentuation(message: message)]
                        }
                    }
                }
            }
        }
    }
    
    private func appendHistory(text:String){
        var recent = recentSearches
        if let dublicate = recentSearches.indexOf(text){
            recent.removeAtIndex(dublicate)
        }
        if recent.count == 100 {
            recent.removeAtIndex(99)
        }
        recentSearches = [text] + recent
    }
    
    private func getAccentuations(word:String) -> [Accentuation]{
        var rez = [Accentuation]()
        let api:String = Constants.url+word.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        if let json = getJSON(api)  {
            let data = parseJSON(json)
            for value in data! {
                let element = value as! NSDictionary
                let accentuation = Accentuation(part:element["class"] as! String, word:element["word"] as! String,states:element["state"]as! [String]) //what if any casting fails?
                rez.append(accentuation)
            }
        }
        return rez
    }
    
    private func getJSON(urlToRequest: String) -> NSData?{
        if let url = NSURL(string: urlToRequest){
            return NSData(contentsOfURL: url)
        }
        else{
            return nil
        }
    }
    
    private func parseJSON(inputData: NSData) -> NSArray?{
        do{
            let jsonDict = try NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions(rawValue: 0)) as! NSArray //what if it fails?
            return jsonDict
        }catch let parseError {
            print(parseError) //returns invalid capability error but still works, why?
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let number = accentuations?.count{
            return number
        }
        else{
            return 0
        }
    }
    
    private struct Constants {
        static let AccentationCellReuseIdentifier = "accentuation"
        static let SpinnerCellReuseIdentifier = "spinner"
        static let url = "http://kirtis.info/api/krc/"
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.AccentationCellReuseIdentifier, forIndexPath: indexPath) as! KirtisTableViewCell
        if let message = accentuations?[indexPath.item].message{
            switch message{
                case "loading":
                    return tableView.dequeueReusableCellWithIdentifier(Constants.SpinnerCellReuseIdentifier, forIndexPath: indexPath) as! SpinnerTableViewCell
                default:
                    cell.title.text = message
                    cell.states.text = ""
            }
        }else{
            cell.title.text = accentuations![indexPath.item].word! + " (" + accentuations![indexPath.item].part! + ")"
            cell.states.text = ""
            for state in accentuations![indexPath.item].states!{
                cell.states.text! += state + " "
            }
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        (segue.destinationViewController as! RecentSearchesTableViewController).textToSearch = textFieldForWord.text
    }
}
