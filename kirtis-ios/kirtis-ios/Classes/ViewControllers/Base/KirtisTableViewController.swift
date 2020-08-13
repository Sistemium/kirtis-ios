//
//  KirtisTableViewController.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 12/11/15.
//  Copyright © 2015 Edgar Jan Vuicik. All rights reserved.
//

import UIKit
import Crashlytics

import Reachability
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


class KirtisTableViewController: UITableViewController, UITextFieldDelegate, AutocompleteTextFieldDelegate, AutocompleteTextFieldDataSource{
    
    @IBOutlet weak var history: UIBarButtonItem!{
        didSet{
            history.title = ""
        }
    }
    @IBOutlet weak var internetAccessIcon: UIBarButtonItem!
    @IBOutlet weak var autocomleteTextField: AutocompleteTextField!{
        didSet{
            autocomleteTextField.layoutSubviews()
            autocomleteTextField.textField.placeholder = "ENTER".localized
            autocomleteTextField.delegate = self
            autocomleteTextField.dataSource = self
        }
    }
    fileprivate var statusCode: HTTPStatusCode?
    var textToSearch:String?{
        didSet{
            if textToSearch != nil{
                var text = textToSearch?.lowercased().replacingOccurrences(of: " ", with: "")
                if text?.count > 0{
                    text = text!.capitalized
                    Answers.logContentView(withName: "Accentuation",
                                                   contentType: "Events",
                                                   contentId: "acc-search",
                                                   customAttributes: [
                                                    "Text": text!
                        ]
                    )
                }
                textToSearch = text
                tableView.tableHeaderView?.layoutSubviews()
                autocomleteTextField.textField.text = text
                search()
            }
        }
    }
    fileprivate var accentuations: [Accentuation]?{
        didSet{
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var accentuate: UIButton!{
        didSet{
            accentuate.setTitle("ACCENTUATE".localized, for: UIControl.State())
            accentuate.layer.cornerRadius = 3
            accentuate.clipsToBounds = true
        }
    }
    
    @objc func shouldButtonAppear(_ note: Notification?){
        DispatchQueue.main.async {[unowned self] in
            if self.splitViewController?.isCollapsed ?? false{
                self.history.title = "HISTORY".localized
            }else{
                self.history.title = ""
            }
            self.tableView.reloadData()
        }
    }
    @IBAction func reachabilityClick(_ sender: AnyObject) {
        let alert = UIAlertController(title: "INTERNET_REQUIRED".localized, message: "", preferredStyle: UIAlertController.Style.alert)
        let message = NSMutableAttributedString(string: "STATUS".localized)
        if ReachabilityService.sharedInstance.hasConnectivity(){
            message.append(NSMutableAttributedString(string: "CONNECTED".localized, attributes: [NSAttributedString.Key.foregroundColor : UIColor.green]))
        }
        else{
            message.append(NSMutableAttributedString(string: "DISCONNECTED".localized, attributes: [NSAttributedString.Key.foregroundColor : UIColor.red]))
        }
        alert.addAction(UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.default, handler: nil))
        alert.setValue(message, forKey: "attributedMessage")
        present(alert, animated: true, completion: nil)
    }
    
    @objc func reachabilityChanged(_ note: Notification?){
        DispatchQueue.main.async {[unowned self] in
            if ReachabilityService.sharedInstance.hasConnectivity(){
                self.internetAccessIcon.tintColor = nil
                self.internetAccessIcon.image = UIImage(named: "Internet")
            }
            else{
                self.internetAccessIcon.image = UIImage(named: "NoInternet")
                self.internetAccessIcon.tintColor = UIColor.red
            }
        }
    }
    
    @IBAction func buttonClick() {
    textToSearch = autocomleteTextField.textField.text
    }
    
    fileprivate func search(){
        autocomleteTextField.textField.resignFirstResponder()
        accentuations = [Accentuation(message: "loading")]
        if textToSearch == nil {
            textToSearch = ""
        }
        statusCode = nil
        if !ReachabilityService.sharedInstance.hasConnectivity(){
            statusCode = .serviceUnavailable
        }
        if textToSearch! == ""{
            statusCode = .badRequest
        }
        let searching = textToSearch
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {[unowned self] in
            var accent : [Accentuation] = []
            if self.statusCode == nil{
                accent = self.getAccentuations(self.textToSearch!)
            }
            DispatchQueue.main.async{[unowned self] in
                if searching == self.textToSearch && self.splitViewController != nil{
                    switch(self.statusCode){
                    case .ok?:
                        self.accentuations = accent
                        self.appendHistory(self.textToSearch!)
                    case .badRequest?:
                        let message = "NOTHING_TYPED".localized
                        self.accentuations = [Accentuation(message: message)]
                    case .notFound?:
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
    
    fileprivate let defaults = UserDefaults.standard
    
    var recentSearches : [String] {
        get{
            return defaults.object(forKey: "RecentSearches") as? [String] ?? []
        }
        // I need update history immediately, best way to do it here,
        //because viewWillAppear is not called on recentSearches Controller if there was no segue (e.g. on Ipad)
        set{
            defaults.set(newValue, forKey: "RecentSearches")
            ((splitViewController?.viewControllers[0] as! UINavigationController).viewControllers[0] as! UITableViewController).tableView.reloadData()
        }
    }
    
    fileprivate func appendHistory(_ text:String){
        var recent = recentSearches
        if let dublicate = recentSearches.firstIndex(of: text){
            recent.remove(at: dublicate)
        }
        if recent.count == 100 {
            recent.remove(at: 99)
        }
        recentSearches = [text] + recent
    }
    
    fileprivate func getAccentuations(_ word:String) -> [Accentuation]{
        var rez = [Accentuation]()
        let api:String = Constants.kirtisAPI+word.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let number = accentuations?.count{
            return number
        }
        else{
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accentuation", for: indexPath) as! KirtisTableViewCell
        if let message = accentuations?[(indexPath as NSIndexPath).item].message{
            switch message{
                case "loading":
                    return tableView.dequeueReusableCell(withIdentifier: "spinner", for: indexPath) as! SpinnerTableViewCell
                default:
                    cell.word.text = ""
                    cell.part.text = ""
                    cell.message.text = message
            }
        }else{
            cell.word.text = accentuations![(indexPath as NSIndexPath).item].word!
            cell.part.text = " (" + accentuations![(indexPath as NSIndexPath).item].part! + ")"
            cell.statesData = accentuations![(indexPath as NSIndexPath).item].states ?? []
        }
        return cell
    }
    
    //MARK: AutocompleteTextFielDelegate
    
    func didShowSuggestions(){
        tableView.tableHeaderView?.constraintWithIdentifier("spaceUnderTextField")!.constant = 0
        if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight{
            tableView.tableHeaderView?.constraintWithIdentifier("topSpace")!.constant = 10
        }
        tableView.tableHeaderView?.frame.size.height = 133 + autocomleteTextField.height.constant + tableView.tableHeaderView!.constraintWithIdentifier("topSpace")!.constant
        UIView.animate(withDuration: 0.5, animations: {[unowned self] in
            self.tableView.tableHeaderView!.layoutIfNeeded()
            self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
        })
        tableView.isScrollEnabled = false
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func didHideSuggestions(){
        tableView.tableHeaderView?.constraintWithIdentifier("spaceUnderTextField")!.constant = 16
        tableView.tableHeaderView?.frame.size.height = 200
        tableView.tableHeaderView?.constraintWithIdentifier("topSpace")!.constant = 71
        UIView.animate(withDuration: 0.5, animations: {[unowned self] in
            self.tableView.tableHeaderView!.layoutIfNeeded()
        })
        tableView.isScrollEnabled = true
        tableView.reloadData()
    }
    
    func didSelectWord(_ word:String){
        textToSearch = word
    }
    
    func isAutocompleteEnabled() -> Bool {
        return defaults.object(forKey: "autocomplete") as? Bool ?? true
    }
    
    //MARK: AutocompleteTextFielDataSource
    
    func getSuggestions(_ word:String) -> [String]{
        var rez = [String]()
        let api:String = Constants.suggestionsAPI+word.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let answer =  RestService.sharedInstance.getJSON(api,timeoutInterval : 0.5)
        if let json = answer.json  {
            let data = RestService.sharedInstance.parseJSON(json)
            if data == nil {
                return rez
            }
            for value in data! {
                let element = value as! String
                rez.append(element)
            }
        }
        return rez
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textToSearch = autocomleteTextField.textField.text
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        accentuations = nil
        textToSearch = nil
        return true
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
        autocomleteTextField.textField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(KirtisTableViewController.shouldButtonAppear(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KirtisTableViewController.reachabilityChanged(_:)), name: NSNotification.Name.reachabilityChanged, object: ReachabilityService.sharedInstance.reachability)
        reachabilityChanged(nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        navigationItem.title = "PROGRAM".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setHidesBackButton(true, animated:false);
        if (!ReachabilityService.sharedInstance.hasConnectivity()){
            internetAccessIcon.image = UIImage(named: "NoInternet")
            internetAccessIcon.tintColor = UIColor.red
        }
        shouldButtonAppear(nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier!{
            case "goToHistory":
                if textToSearch != nil || accentuations?.count>0{
                    (segue.destination as! RecentSearchesTableViewController).textToSearch = textToSearch
                }
                else{
                    (segue.destination as! RecentSearchesTableViewController).textToSearch = nil
                }

        default:
            break
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
}
