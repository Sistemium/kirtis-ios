//
//  Accentuation.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 12/11/15.
//  Copyright © 2015 Edgar Jan Vuicik. All rights reserved.
//

import Foundation

struct Accentuation{
    var part:String?
    var word:String?
    var states:[String]?
    var message:String? //for errors or warnings
    
    fileprivate init(){
    }
    
    init(part: String?, word:String?, states:[String]?){
        self.part = part
        self.word = word
        self.states = states
    }
    init(message: String){
        self.message = message
    }
}
