//
//  AutocompleteTextFieldDelegate.swift
//  kirtis-ios
//
//  Created by Edgar Jan Vuicik on 01/04/16.
//  Copyright © 2016 Sistemium. All rights reserved.
//

protocol AutocompleteTextFieldDelegate {
    func didShowSuggestions()
    func didHideSuggestions()
    func didSelectWord(word:String)
    func isAutocompleteEnabled() -> Bool
}