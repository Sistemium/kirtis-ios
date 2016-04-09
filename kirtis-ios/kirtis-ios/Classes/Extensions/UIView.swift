//
//  UIView.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 07/04/16.
//  Copyright © 2016 Sistemium. All rights reserved.
//
import UIKit

extension UIView{
    func constraintWithIdentifier(identifier:String) -> NSLayoutConstraint?{
        if let constraint = (constraints.filter{$0.identifier == identifier}.first) {
            return constraint
        }
        return nil
    }
}
 