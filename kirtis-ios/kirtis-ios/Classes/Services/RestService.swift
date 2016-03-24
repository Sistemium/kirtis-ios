//
//  RestService.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 23/03/16.
//  Copyright © 2016 Sistemium. All rights reserved.
//

import UIKit

class RestService{
    static let sharedInstance = RestService()
    private init() {}
    private var eTag:String?{
        get{
            return NSUserDefaults.standardUserDefaults().objectForKey("eTag") as? String ?? nil
        }
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "eTag")
        }
    }
    
    func getJSON(urlToRequest: String, cashed : Bool = false) -> (json : NSData?,statusCode : HTTPStatusCode?){
        var response: NSURLResponse?
        do{
            if let url = NSURL(string: urlToRequest){
                let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: 4.0)
                if cashed{
                    request.addValue(eTag ?? "", forHTTPHeaderField: "If-None-Match")
                }
                let rez = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
                eTag = (response as! NSHTTPURLResponse).allHeaderFields["eTag"] as? String
                return (rez,HTTPStatusCode(HTTPResponse: response as? NSHTTPURLResponse))
            }
        }
        catch{
            
        }
        return (nil , nil)
    }
    
    func parseJSON(inputData: NSData) -> NSArray?{
        do{
            let jsonDict = try NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions(rawValue: 0)) as! NSArray
            return jsonDict
        }catch let parseError {
            print(parseError)
        }
        return nil
    }
    
    func parseJSONDictionary(inputData: NSData) -> NSDictionary?{
        do{
            let jsonDict = try NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions(rawValue: 0)) as! NSDictionary
            return jsonDict
        }catch let parseError {
            print(parseError)
        }
        return nil
    }
}
