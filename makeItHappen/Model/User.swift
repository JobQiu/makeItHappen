//
//  User.swift
//  makeItHappen
//
//  Created by CongminQiu on 6/9/18.
//  Copyright © 2018 CongminQiu. All rights reserved.
//

import Foundation

import Cocoa

final class User: NSObject, NSCoding{
    var account: String
    var password_md5: String
    var token: String
    var userId: Int
    
    init(account: String, password_md5: String, token:String, userId: Int) {
        self.account = account
        self.password_md5 = password_md5
        self.token = token
        self.userId = userId
    }
    
    init?(coder aDecoder: NSCoder) {
        self.account = (aDecoder.decodeObject(forKey: "account") as? String) ?? ""
        self.password_md5 = (aDecoder.decodeObject(forKey: "password_md5") as? String) ?? ""
        self.token = (aDecoder.decodeObject(forKey: "token") as? String) ?? ""
        self.userId = Int(aDecoder.decodeInt32(forKey: "userId"))
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(account, forKey: "account")
        aCoder.encode(password_md5, forKey: "password_md5")
        aCoder.encode(token, forKey: "token")
        aCoder.encode(userId, forKey: "userId")
    }
}
