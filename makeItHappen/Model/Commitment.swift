//
//  Commitment.swift
//  makeItHappen
//
//  Created by CongminQiu on 6/8/18.
//  Copyright © 2018 CongminQiu. All rights reserved.
//

import Foundation
import Cocoa


protocol CommitmentTimerProtocol {
    func timeOnTimer(_ timer: Commitment, time: TimeInterval)
}

final class Commitment: NSObject, NSCoding{
    
    var content: String
    var id:Int64
    var processing:Int
    var timeSpend:Int
    var totalTask:Int
    var type:String
    var priority: Int
    var done:Int
    
    var timer: Timer? = nil
    var delegate: CommitmentTimerProtocol?
    var elapsedTime: TimeInterval = 0
    var startTime: Date?
    
    init(content: String,
         id:Int64,
         processing:Int,
         timeSpend:Int,
         totalTask:Int,
         type:String,
         priority:Int,
         done:Int) {
        self.content = content
        self.id = id
        self.processing = processing
        self.timeSpend = timeSpend
        self.totalTask = totalTask
        self.type = type
        self.priority = priority
        self.done = done
    }
    
    init?(coder aDecoder: NSCoder) {
        self.content = (aDecoder.decodeObject(forKey: "content") as? String) ?? ""
        self.type = (aDecoder.decodeObject(forKey: "type") as? String) ?? ""
        
        self.id = Int64(aDecoder.decodeInt64(forKey: "id"))
        
        self.processing = Int(aDecoder.decodeInt32(forKey: "processing"))
        
        self.timeSpend = Int(aDecoder.decodeInt32(forKey: "timeSpend"))
        
        self.totalTask = Int(aDecoder.decodeInt32(forKey: "totalTask"))
        
        self.priority = Int(aDecoder.decodeInt32(forKey: "priority"))
        
        self.done = Int(aDecoder.decodeInt32(forKey: "done"))
        
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(content, forKey: "content")
        aCoder.encode(type, forKey: "type")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(processing, forKey: "processing")
        aCoder.encode(timeSpend, forKey: "timeSpend")
        aCoder.encode(totalTask, forKey: "totalTask")
        aCoder.encode(priority, forKey: "priority")
        aCoder.encode(done, forKey: "done")
        
    }
    
    @objc dynamic func timerAction() {
        guard let startTime = startTime else {
            return
        }
        
        elapsedTime = TimeInterval(timeSpend)-startTime.timeIntervalSinceNow
        
        let secondsRemaining = (elapsedTime).rounded()
        
        delegate?.timeOnTimer(self, time: secondsRemaining)
        
    }
    
    func startTimer() {
        startTime = Date()
        elapsedTime = TimeInterval(timeSpend)
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(timerAction),
                                     userInfo: nil,
                                     repeats: true)
        timerAction()
    }
    
    func stopTimer() {
        // really just pauses the timer
        timer?.invalidate()
        timer = nil
        
        timerAction()
    }
}
