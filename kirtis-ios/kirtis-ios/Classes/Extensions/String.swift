//
//  String.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 18/03/16.
//  Copyright © 2016 Sistemium. All rights reserved.
//

import Foundation

extension String {
    var localized : String {
        return LocalizationService.sharedInstance.localize(self)
    }
}
