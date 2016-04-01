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
    
    func getJSON(urlToRequest: String, cashed : Bool = false, timeoutInterval : Double = 4.0) -> (json : NSData?,statusCode : HTTPStatusCode?){
        var response: NSURLResponse?
        do{
            if let url = NSURL(string: urlToRequest){
                //sleep(4) //for testing
                let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: timeoutInterval)
                request.addValue(UIDevice.currentDevice().identifierForVendor!.UUIDString, forHTTPHeaderField: "deviceUUID")
                if cashed{
                    request.addValue(eTag ?? "", forHTTPHeaderField: "If-None-Match")
                }
                let rez = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
                if cashed{
                    eTag = (response as! NSHTTPURLResponse).allHeaderFields["eTag"] as? String
                }
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
