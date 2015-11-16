//
//  KirtisTableViewController.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 12/11/15.
//  Copyright © 2015 Edgar Jan Vuicik. All rights reserved.
//

import UIKit

class KirtisTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var history: UIBarButtonItem!
    @IBOutlet weak var textFieldForWord: UITextField!
    var textToSearch:String?
    private let url = "http://kirtis.info/api/krc/"
    private var accentuations: [Accentuation]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
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
        if !splitViewController!.collapsed{
            navigationItem.rightBarButtonItems = []
        }else{
            navigationItem.rightBarButtonItems = [history]
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        search()
        return true
    }
    
    private func search(){
        var text = textFieldForWord.text!.lowercaseString
        if text.characters.count > 0{
            text = text.substringToIndex(text.startIndex.advancedBy(1)).uppercaseString + text.substringFromIndex(text.startIndex.advancedBy(1))
        }
        accentuations = getAccentuations(text)  //what if it fails?
        if accentuations?.count > 0 {
            appendHistory(text)
        }
        else{
            accentuations?.append(Accentuation(message: "Žodis nerastas"))
        }
        tableView.reloadData()
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
        let api:String = url+word.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
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
    
    struct Storyboard {
        static let CellReuseIdentifier = "accentuation"
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! KirtisTableViewCell
        if let message = accentuations![indexPath.item].message{
            cell.title.text = message
            cell.states.text = ""
        }else{
            cell.title.text = accentuations![indexPath.item].word! + " (" + accentuations![indexPath.item].part! + ")"
            cell.states.text = ""
            for state in accentuations![indexPath.item].states!{
                cell.states.text! += state + " "
            }
        }
        return cell
    }
}
