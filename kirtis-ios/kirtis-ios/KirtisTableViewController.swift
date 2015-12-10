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
    
    
    @IBOutlet weak var accentuate: UIButton!{
        didSet{
            accentuate.layer.cornerRadius = 3
            accentuate.clipsToBounds = true
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
    
    @IBAction func buttonClick() {
        textFieldForWord.resignFirstResponder()
        textToSearch = textFieldForWord.text
        search()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textToSearch = textFieldForWord.text
        search()
        return true
    }
    
    private func search(){
        self.accentuations = [Accentuation(message: "loading")]
        if textToSearch == nil {
            textToSearch = ""
        }
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
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var recentSearches : [String] {
        get{
            return defaults.objectForKey("RecentSearches") as? [String] ?? []
        }
        // I need update history immediately, best way to do it here,
        //because viewWillAppear is not called on recentSearches Controller if there was no segue (e.g. Landscape mode)
        set{
            defaults.setObject(newValue, forKey: "RecentSearches")
            ((self.splitViewController?.viewControllers[0] as! UINavigationController).visibleViewController as! UITableViewController).tableView.reloadData()
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
        if let json = appDelegate.getJSON(api)  {
            let data = appDelegate.parseJSON(json)
            for value in data! {
                let element = value as! NSDictionary
                let accentuation = Accentuation(part:element["class"] as! String, word:element["word"] as! String,states:element["state"] as! [String]) //what if any casting fails?
                rez.append(accentuation)
            }
        }
        return rez
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
                    cell.word.text = ""
                    cell.part.text = ""
                    cell.message.text = message
            }
        }else{
            cell.word.text = accentuations![indexPath.item].word!
            cell.part.text = " (" + accentuations![indexPath.item].part! + ")"
            cell.statesData = accentuations![indexPath.item].states!
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        (segue.destinationViewController as! RecentSearchesTableViewController).textToSearch = textFieldForWord.text
    }
}
