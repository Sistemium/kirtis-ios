//
//  String.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 18/03/16.
//  Copyright © 2016 Sistemium. All rights reserved.
//

import Foundation

extension String {
    func localized(language:String) -> String {
        return NSLocalizedString(self, bundle: NSBundle(path:NSBundle.mainBundle().pathForResource(language , ofType:"lproj")!)!, value: "", comment: "")
    }
}