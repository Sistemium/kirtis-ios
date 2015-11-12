//
//  KirtisTableViewController.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 12/11/15.
//  Copyright © 2015 Edgar Jan Vuicik. All rights reserved.
//

import UIKit

class KirtisTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var history: UIBarButtonItem!
    @IBOutlet weak var textFieldForWord: UITextField!
    var textToSearch:String?{
        didSet{
            textFieldForWord.text = textToSearch
            search()
        }
    }
    private let url = "http://kirtis.info/api/krc/"
    private var accentuations: [Accentuation]?
    var isWidthRegular = false{
        didSet{
            if isWidthRegular{
                navigationItem.rightBarButtonItems = []
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        textFieldForWord.delegate = self
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        search()
        return true
    }
    
    private func search(){
        accentuations = getAccentuations(textFieldForWord.text!)  //what if it fails?
        if accentuations?.count > 0 {
            appendHistory(textFieldForWord.text!)
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
        if isWidthRegular {
            performSegueWithIdentifier("showHistory", sender: self)
        }
    }
    
    private func getAccentuations(word:String) -> [Accentuation]{
        var rez = [Accentuation]()
        if getJSON(url+word) != nil {
            let data = parseJSON(getJSON(url+word)!)
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
        cell.title.text = accentuations![indexPath.item].word + " (" + accentuations![indexPath.item].part + ")"
        cell.states.text = ""
        for state in accentuations![indexPath.item].states{
            cell.states.text! += state + " "
        }
        return cell
    }
    
    @IBAction func goBack(segue:UIStoryboardSegue){
    }
    
}
