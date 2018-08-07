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
    var recentUpdateTime: String = ""
    var encryptKey:String
    
    init(keyloggerLocation: String, startAtLogin: Bool, encryptKey:String) {
        self.keyloggerLocation = keyloggerLocation
        self.startAtLogin = startAtLogin
        self.encryptKey = encryptKey
    }
    
    init?(coder aDecoder: NSCoder) {
        self.keyloggerLocation = (aDecoder.decodeObject(forKey: "keyloggerLocation") as? String) ?? ""
        self.startAtLogin = (aDecoder.decodeBool(forKey: "startAtLogin"))
        self.encryptKey = (aDecoder.decodeObject(forKey: "encryptKey") as? String) ?? ""
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(keyloggerLocation, forKey: "keyloggerLocation")
        aCoder.encode(startAtLogin, forKey: "startAtLogin")
        aCoder.encode(encryptKey, forKey: "encryptKey")
        
    }
    
}

