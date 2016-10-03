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
    fileprivate init() {}
    fileprivate var eTag:[String:String]?{
        get{
            return UserDefaults.standard.object(forKey: "eTag") as? [String:String] ?? nil
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "eTag")
        }
    }
    
    func getJSON(_ urlToRequest: String, cashingKey : String? = nil, timeoutInterval : Double = 4.0) -> (json : Data?,statusCode : HTTPStatusCode?){
        var response: URLResponse?
        if let url = URL(string: urlToRequest){
            //sleep(4) //for testing
            let request = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: timeoutInterval)
            request.addValue(UIDevice.current.identifierForVendor!.uuidString, forHTTPHeaderField: "deviceUUID")
            if cashingKey != nil{
                request.addValue(eTag?[cashingKey!] ?? "", forHTTPHeaderField: "If-None-Match")
            }
            let rez = try? NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response)
            if response != nil && cashingKey != nil{
                var e = eTag ?? [:]
                e[cashingKey!] = (response as! HTTPURLResponse).allHeaderFields["eTag"] as? String
                eTag = e
            }
            return (rez,HTTPStatusCode(HTTPResponse: response as? HTTPURLResponse))
        }
        return (nil , nil)
    }
    
    func parseJSON(_ inputData: Data) -> NSArray?{
        return try? JSONSerialization.jsonObject(with: inputData, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! NSArray
    }
    
    func parseJSONDictionary(_ inputData: Data) -> NSDictionary?{
        return try? JSONSerialization.jsonObject(with: inputData, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! NSDictionary
    }

}
