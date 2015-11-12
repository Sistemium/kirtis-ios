//
//  Accentuation.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 12/11/15.
//  Copyright © 2015 Edgar Jan Vuicik. All rights reserved.
//

import Foundation

class Accentuation{
    var part:String
    var word:String
    var state:[String]
    
    required init(part: String, word:String, state:[String]){
        self.part = part
        self.word = word
        self.state = state
    }
}