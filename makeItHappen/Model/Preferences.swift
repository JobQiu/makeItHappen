//
//  User.swift
//  makeItHappen
//
//  Created by CongminQiu on 6/9/18.
//  Copyright © 2018 CongminQiu. All rights reserved.
//

import Foundation

import Cocoa

final class Preferences: NSObject, NSCoding{
    var keyloggerLocation: String
    var startAtLogin: Bool
    
    init(keyloggerLocation: String, startAtLogin: Bool) {
        self.keyloggerLocation = keyloggerLocation
        self.startAtLogin = startAtLogin
    }
    
    init?(coder aDecoder: NSCoder) {
        self.keyloggerLocation = (aDecoder.decodeObject(forKey: "keyloggerLocation") as? String) ?? ""
        self.startAtLogin = (aDecoder.decodeBool(forKey: "startAtLogin"))
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(keyloggerLocation, forKey: "keyloggerLocation")
        aCoder.encode(startAtLogin, forKey: "startAtLogin")
        
    }
    
}

