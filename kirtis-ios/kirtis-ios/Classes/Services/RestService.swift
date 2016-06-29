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
    private var eTag:[String:String]?{
        get{
            return NSUserDefaults.standardUserDefaults().objectForKey("eTag") as? [String:String] ?? nil
        }
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "eTag")
        }
    }
    
    func getJSON(urlToRequest: String, cashingKey : String? = nil, timeoutInterval : Double = 4.0) -> (json : NSData?,statusCode : HTTPStatusCode?){
        var response: NSURLResponse?
        if let url = NSURL(string: urlToRequest){
            //sleep(4) //for testing
            let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: timeoutInterval)
            request.addValue(UIDevice.currentDevice().identifierForVendor!.UUIDString, forHTTPHeaderField: "deviceUUID")
            if cashingKey != nil{
                request.addValue(eTag?[cashingKey!] ?? "", forHTTPHeaderField: "If-None-Match")
            }
            let rez = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
            if cashingKey != nil{
                var e = eTag ?? [:]
                e[cashingKey!] = (response as! NSHTTPURLResponse).allHeaderFields["eTag"] as? String
                eTag = e
            }
            return (rez,HTTPStatusCode(HTTPResponse: response as? NSHTTPURLResponse))
        }
        return (nil , nil)
    }
    
    func parseJSON(inputData: NSData) -> NSArray?{
        return try? NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions(rawValue: 0)) as! NSArray
    }
    
    func parseJSONDictionary(inputData: NSData) -> NSDictionary?{
        return try? NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions(rawValue: 0)) as! NSDictionary
    }

}
