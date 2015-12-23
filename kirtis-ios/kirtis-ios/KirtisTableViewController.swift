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
import ReachabilitySwift

class KirtisTableViewController: UITableViewController, UITextFieldDelegate{
    
    var reachability :Reachability?
    @IBOutlet var history: UIBarButtonItem!
    @IBOutlet var internetAccessIcon: UIBarButtonItem!
    @IBOutlet var textFieldForWord: UITextField!
    private var statusCode = 0
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var textToSearch:String?{
        didSet{
            var text = textToSearch?.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "")
            if text?.characters.count > 0{
                text = text!.substringToIndex(text!.startIndex.advancedBy(1)).uppercaseString + text!.substringFromIndex(text!.startIndex.advancedBy(1)) //uppercase
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
        do{
        reachability = try Reachability.reachabilityForInternetConnection()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
        try reachability?.startNotifier();
        }catch let error as NSError {
            print("\(error), \(error.userInfo)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reachabilityChanged(NSNotification(name: "", object: nil))
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
    @IBAction func reachabilityClick(sender: AnyObject) {
        let currentLanguageBundle = NSBundle(path:NSBundle.mainBundle().pathForResource(self.appDelegate.userLanguage , ofType:"lproj")!)
        let alert = UIAlertController(title: NSLocalizedString("Internet connection is required", bundle: currentLanguageBundle!, value: "Internet connection is required", comment: "Internet connection is required"), message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let message = NSMutableAttributedString(string: NSLocalizedString("Status: ", bundle: currentLanguageBundle!, value: "Status: ", comment: "Status: "))
        if hasConnectivity(){
            message.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Connected", bundle: currentLanguageBundle!, value: "Connected", comment: "Connected"), attributes: [NSForegroundColorAttributeName : UIColor.greenColor()]))
        }
        else{
            message.appendAttributedString(NSMutableAttributedString(string: NSLocalizedString("Disconnected", bundle: currentLanguageBundle!, value: "Disconnected", comment: "Disconnected"), attributes: [NSForegroundColorAttributeName : UIColor.redColor()]))
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", bundle: currentLanguageBundle!, value: "Ok", comment: "Ok"), style: UIAlertActionStyle.Default, handler: nil))
        alert.setValue(message, forKey: "attributedMessage")
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func reachabilityChanged(note: NSNotification){
        let currentLanguageBundle = NSBundle(path:NSBundle.mainBundle().pathForResource(self.appDelegate.userLanguage , ofType:"lproj")!)
        if hasConnectivity(){
            internetAccessIcon.tintColor = nil
            internetAccessIcon.image = UIImage(named: NSLocalizedString("Internet", bundle: currentLanguageBundle!, value: "Internet", comment: "Internet"))
        }
        else{
            internetAccessIcon.image = UIImage(named: NSLocalizedString("NoInternet", bundle: currentLanguageBundle!, value: "NoInternet", comment: "NoInternet"))
            internetAccessIcon.tintColor = UIColor.redColor()
        }
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        accentuations = nil
        textToSearch = nil
        return true
    }
    
    @IBAction func buttonClick() {
        textFieldForWord.resignFirstResponder()
        textToSearch = textFieldForWord.text
        search()
    }
    
    private func hasConnectivity() -> Bool {
        let networkStatus: Int = reachability!.currentReachabilityStatus.hashValue
        return networkStatus != 0
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
        self.statusCode = 0
        if !self.hasConnectivity(){
            self.statusCode = -1
        }
        if textToSearch! == ""{
            statusCode = 400
        }
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)){
            var accent : [Accentuation] = []
            if self.statusCode == 0{
                accent = self.getAccentuations(self.textToSearch!)
            }
            dispatch_async(dispatch_get_main_queue()){
                let currentLanguageBundle = NSBundle(path:NSBundle.mainBundle().pathForResource(self.appDelegate.userLanguage , ofType:"lproj")!)
                switch(self.statusCode){
                case 200:
                    self.accentuations = accent
                    self.appendHistory(self.textToSearch!)
                case 400:
                    let message = NSLocalizedString("Nothing was typed", bundle: currentLanguageBundle!, value: "Nothing was typed", comment: "Nothing was typed")
                    self.accentuations = [Accentuation(message: message)]
                case 404:
                    let message = NSLocalizedString("Word is not found", bundle: currentLanguageBundle!, value: "Word is not found", comment: "Word is not found")
                    self.accentuations = [Accentuation(message: message)]
                default:
                    let message = NSLocalizedString("No internet access", bundle: currentLanguageBundle!, value: "No internet access", comment: "No internet access")
                    self.accentuations = [Accentuation(message: message)]
                    break
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
        let answer =  appDelegate.getJSON(api)
        statusCode = answer.statusCode
        if let json = answer.json  {
            let data = appDelegate.parseJSON(json)
                if data == nil {
                    return rez
                }
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
        switch segue.identifier!{
            case "goToHistory":
                if textToSearch != nil || accentuations?.count>0{
                    (segue.destinationViewController as! RecentSearchesTableViewController).textToSearch = textToSearch
                }
                else{
                    (segue.destinationViewController as! RecentSearchesTableViewController).textToSearch = nil
                }

        default:
            break
        }
    }
    
}
