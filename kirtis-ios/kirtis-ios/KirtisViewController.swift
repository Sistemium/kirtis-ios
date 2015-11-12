//
//  KirtisViewController.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 11/11/15.
//  Copyright © 2015 Edgar Jan Vuicik. All rights reserved.
//

import UIKit

class KirtisViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var textFieldForWord: UITextField!
    private let url = "http://kirtis.info/api/krc/"
    var accentuations: [Accentuation]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldForWord.delegate = self
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        accentuations = getAccentuations(textField.text!)  //what if it fails?
        return true
    }
    
    private func getAccentuations(word:String) -> [Accentuation]{
        var rez = [Accentuation]()
        if getJSON(url+word) != nil {
            let data = parseJSON(getJSON(url+word)!)
            for value in data! {
                let element = value as! NSDictionary
                let accentuation = Accentuation(part:element["class"] as! String, word:element["word"] as! String,state:element["state"]as! [String]) //what if any casting fails?
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
}
