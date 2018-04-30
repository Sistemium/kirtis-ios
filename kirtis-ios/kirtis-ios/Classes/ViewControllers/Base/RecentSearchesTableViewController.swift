//
//  RecentSearchesTableViewController.swift
//  Created by Edgar Jan Vuicik on 01/11/15.

import UIKit

class RecentSearchesTableViewController: UITableViewController {
    
    @IBOutlet var close: UIBarButtonItem!{
        didSet{
            close.title = "CLOSE".localized
        }
    }
    var textToSearch:String? //I dont want to lose current search (opening history destroys KirtisTableView)
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "search", sender: textToSearch)
    }
    
    fileprivate let defaults = UserDefaults.standard
    
    var recentSearches : [String] {
        get{
            return defaults.object(forKey: "RecentSearches") as? [String] ?? []
        }
        set{
            defaults.set(newValue, forKey: "RecentSearches")
        }
    }
    
    @objc func shouldButtonAppear(){
        if splitViewController?.isCollapsed ?? false{
            close.isEnabled = true
            close.title = "CLOSE".localized
        }else{
            close.isEnabled = false
            close.title = ""
        }
    }
    
    //MARK: Table view controller
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = recentSearches[(indexPath as NSIndexPath).row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "search", sender: recentSearches[(indexPath as NSIndexPath).item])
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if textToSearch == recentSearches[(indexPath as NSIndexPath).row]{
                textToSearch = nil
            }
            var recent = recentSearches
            recent.remove(at: (indexPath as NSIndexPath).row)
            recentSearches = recent
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  cell = UITableViewCell()
        if recentSearches.count == 0 {
            cell.textLabel?.textAlignment = .center
            let message = "HISTORY_EMPTY".localized
            cell.textLabel?.text = message
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if recentSearches.count>0 {
            return 0
        }
        return 50
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "HISTORY".localized
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        NotificationCenter.default.addObserver(self, selector: #selector(RecentSearchesTableViewController.shouldButtonAppear), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        shouldButtonAppear()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = (segue.destination as! UINavigationController).visibleViewController as! KirtisTableViewController
        destination.navigationItem.setHidesBackButton(true, animated: false)
        if sender != nil{
            destination.textToSearch = (sender as! String)
        }
    }
    
    @IBAction func goToHistory(_ segue:UIStoryboardSegue){
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }

}
