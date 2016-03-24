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
    
    @IBOutlet weak var history: UIBarButtonItem!{
        didSet{
            history.title = "HISTORY".localized
        }
    }
    @IBOutlet weak var internetAccessIcon: UIBarButtonItem!
    @IBOutlet weak var textFieldForWord: UITextField!{
        didSet{
            textFieldForWord.placeholder = "ENTER".localized
        }
    }
    private var statusCode: HTTPStatusCode?
    var textToSearch:String?{
        didSet{
            var text = textToSearch?.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "")
            if text?.characters.count > 0{
                text = text!.substringToIndex(text!.startIndex.advancedBy(1)).uppercaseString + text!.substringFromIndex(text!.startIndex.advancedBy(1)) //uppercase
                Answers.logContentViewWithName("Accentuation",
                    contentType: "Events",
                    contentId: "acc-search",
                    customAttributes: [
                        "Text": text!
                    ]
                )
            }
            textToSearch = text
        }
    }
    private var accentuations: [Accentuation]?{
        didSet{
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var accentuate: UIButton!{
        didSet{
            accentuate.setTitle("ACCENTUATE".localized, forState: .Normal)
            accentuate.layer.cornerRadius = 3
            accentuate.clipsToBounds = true
        }
    }
    
    func shouldButtonAppear(note: NSNotification?){
        if splitViewController?.collapsed ?? false{
            history.enabled = true
            history.title = "HISTORY".localized
        }else{
            history.enabled = true
            history.title = ""
        }
    }
    @IBAction func reachabilityClick(sender: AnyObject) {
        let alert = UIAlertController(title: "INTERNET_REQUIRED".localized, message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let message = NSMutableAttributedString(string: "STATUS".localized)
        if ReachabilityService.sharedInstance.hasConnectivity(){
            message.appendAttributedString(NSMutableAttributedString(string: "CONNECTED".localized, attributes: [NSForegroundColorAttributeName : UIColor.greenColor()]))
        }
        else{
            message.appendAttributedString(NSMutableAttributedString(string: "DISCONNECTED".localized, attributes: [NSForegroundColorAttributeName : UIColor.redColor()]))
        }
        alert.addAction(UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.Default, handler: nil))
        alert.setValue(message, forKey: "attributedMessage")
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func reachabilityChanged(note: NSNotification?){
        if ReachabilityService.sharedInstance.hasConnectivity(){
            internetAccessIcon.tintColor = nil
            internetAccessIcon.image = UIImage(named: "Internet")
        }
        else{
            internetAccessIcon.image = UIImage(named: "NoInternet")
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
        self.statusCode = nil
        if !ReachabilityService.sharedInstance.hasConnectivity(){
            self.statusCode = .ServiceUnavailable
        }
        if textToSearch! == ""{
            statusCode = .BadRequest
        }
        let searching = textToSearch
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)){
            var accent : [Accentuation] = []
            if self.statusCode == nil{
                accent = self.getAccentuations(self.textToSearch!)
            }
            dispatch_async(dispatch_get_main_queue()){
                if searching == self.textToSearch{
                    switch(self.statusCode){
                    case .OK?:
                        self.accentuations = accent
                        self.appendHistory(self.textToSearch!)
                    case .BadRequest?:
                        let message = "NOTHING_TYPED".localized
                        self.accentuations = [Accentuation(message: message)]
                    case .NotFound?:
                        let message = "WORD_NOT_FOUND".localized
                        self.accentuations = [Accentuation(message: message)]
                    default:
                        let message = "NO_INTERNET".localized
                        self.accentuations = [Accentuation(message: message)]
                        break
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
        //because viewWillAppear is not called on recentSearches Controller if there was no segue (e.g. on Ipad)
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
        let api:String = Constants.kirtisAPI+word.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let answer =  RestService.sharedInstance.getJSON(api)
        statusCode = answer.statusCode
        if let json = answer.json  {
            let data = RestService.sharedInstance.parseJSON(json)
            if data == nil {
                return rez
            }
            for value in data! {
                let element = value as! NSDictionary
                let accentuation = Accentuation(part:element["class"] as? String, word:element["word"] as? String,states:element["state"] as? [String])
                rez.append(accentuation)
            }
        }

        return rez
    }
    
    //Mark: Table data
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let number = accentuations?.count{
            return number
        }
        else{
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("accentuation", forIndexPath: indexPath) as! KirtisTableViewCell
        if let message = accentuations?[indexPath.item].message{
            switch message{
                case "loading":
                    return tableView.dequeueReusableCellWithIdentifier("spinner", forIndexPath: indexPath) as! SpinnerTableViewCell
                default:
                    cell.word.text = ""
                    cell.part.text = ""
                    cell.message.text = message
            }
        }else{
            cell.word.text = accentuations![indexPath.item].word!
            cell.part.text = " (" + accentuations![indexPath.item].part! + ")"
            cell.statesData = accentuations![indexPath.item].states ?? []
        }
        return cell
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        textFieldForWord.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "shouldButtonAppear:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: ReachabilityService.sharedInstance.reachability)
        reachabilityChanged(nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.navigationItem.title = "PROGRAM".localized
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated:false);
        if let text = textToSearch{
            textFieldForWord.text = text
            search()
        }
        if (!ReachabilityService.sharedInstance.hasConnectivity()){
            internetAccessIcon.image = UIImage(named: "NoInternet")
            internetAccessIcon.tintColor = UIColor.redColor()
        }
        shouldButtonAppear(nil)
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
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        UIMenuController.sharedMenuController().setMenuVisible(false, animated: true)
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
