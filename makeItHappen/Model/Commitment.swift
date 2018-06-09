//
//  Commitment.swift
//  makeItHappen
//
//  Created by CongminQiu on 6/8/18.
//  Copyright © 2018 CongminQiu. All rights reserved.
//

import Foundation
import Cocoa

final class Commitment: NSObject, NSCoding{
    
    var title: String
    var completed = false
    
    init(title: String) {
        self.title = title
    }
    
    init?(coder aDecoder: NSCoder) {
        self.title = (aDecoder.decodeObject(forKey: "title") as? String) ?? ""
        self.completed = aDecoder.decodeBool(forKey: "completed")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(completed, forKey: "completed")
    }
}
