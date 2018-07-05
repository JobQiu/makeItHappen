//
//  MyCommitment.swift
//  makeItHappen
//
//  Created by CongminQiu on 6/8/18.
//  Copyright © 2018 CongminQiu. All rights reserved.
//

import Cocoa

class MyCommitment: NSWindowController, CommitmentTimerProtocol {
    
    @IBAction func ShowTaskList(_ sender: Any) {
    }
    
    
    @IBOutlet weak var taskText: NSTextField!
    
    func timeOnTimer(_ timer: Commitment, time: TimeInterval) {
        self.timeLabel.stringValue = (textToDisplay(for: time,commitment: timer))
        
    }
    
    @objc func onWakeNote(note: NSNotification) {
        self.commitment.startTimer()
    }
    
    @objc func onSleepNote(note: NSNotification) {
        self.commitment.stopTimer()
    }
    
    func fileNotifications() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(onWakeNote(note:)),
            name: NSWorkspace.didWakeNotification, object: nil)
        
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(onSleepNote(note:)),
            name: NSWorkspace.willSleepNotification, object: nil)
    }
    
    private func updateTimeSpend(type:String,id:Int64,timeSpend:Int){
        
        var request = URLRequest(url: URL(string: self.user.homepage+"/api/updateTimeSpend?type="+self.commitment.type+"&id="+(String)(self.commitment.id)+"&timeSpend="+String(timeSpend))!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
        }).resume()
    }
    
    private func textToDisplay(for timeRemaining: TimeInterval, commitment:Commitment) -> String {
        if timeRemaining<3600 {
            let minutesRemaining = floor(timeRemaining / 60)
            let secondsRemaining = timeRemaining - (minutesRemaining * 60)
            let minutesDisplay = String(format: "%02d",Int(minutesRemaining))
            let secondsDisplay = String(format: "%02d", Int(secondsRemaining))
            if((Int(timeRemaining)) % 60==0 && (Int(timeRemaining))>60){
                commitment.timeSpend = commitment.timeSpend+60
                updateTimeSpend(type: commitment.type, id: commitment.id, timeSpend: Int(timeRemaining))
            }
            let timeRemainingDisplay = "00:\(minutesDisplay):\(secondsDisplay)"
            return timeRemainingDisplay
        }else{
            let hoursRemaining = floor(timeRemaining/3600)
            let minutesRemaining = floor((timeRemaining - hoursRemaining*3600) / 60)
            let secondsRemaining = timeRemaining - (minutesRemaining * 60) - hoursRemaining*3600
            let hoursDisplay = String(format:"%02d",Int(hoursRemaining))
            let minutesDisplay = String(format: "%02d",Int(minutesRemaining))
            let secondsDisplay = String(format: "%02d", Int(secondsRemaining))
            if((Int(timeRemaining)) % 60==0){
               
                commitment.timeSpend = commitment.timeSpend+60
                updateTimeSpend(type: commitment.type, id: commitment.id, timeSpend: Int(timeRemaining))
            }
            let timeRemainingDisplay = "\(hoursDisplay):\(minutesDisplay):\(secondsDisplay)"
            return timeRemainingDisplay
        }
    }
    
    @IBOutlet weak var progress: NSProgressIndicator!
    @IBOutlet weak var doneTaskLabel: NSTextField!
    @IBOutlet weak var totalTaskLabel: NSTextField!
    
    @IBOutlet weak var dreamLabel: NSTextField!
    
    @IBOutlet weak var timeLabel: NSTextField!
    
   
    @IBAction func refreshAction(_ sender: Any) {
        self.progress.isHidden = false
        self.progress.startAnimation(self)
        self.commitment.stopTimer()
        var request = URLRequest(url: URL(string: self.user.homepage+"/api/changeATask?userId="+String(self.user.userId)+"&type="+self.commitment.type+"&id="+(String)(self.commitment.id)+"&priority="+String(self.commitment.priority)+"&timeSpend="+String(Int(self.commitment.elapsedTime)))!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                if data == nil{
                    return
                }
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
                if json.keys.contains("content"){
                    let content = json["content"] as! String
                    let type = json["type"] as! String
                    let timeSpend = json["timeSpend"] as! Int
                    let id = json["id"] as! Int64
                    let priority = json["priority"] as! Int
                    var done = json["done"] as! Int
                    
                    let totalTask = json["totalTask"] as! Int
                    if done != totalTask{
                        done = done + 1
                    }
                    DispatchQueue.main.async {
                        self.taskText.stringValue = content
                        self.totalTaskLabel.stringValue = "\(totalTask)"
                        
                        self.doneTaskLabel.stringValue = "\(done)"
                        self.commitment.priority = priority
                        self.commitment.timeSpend = timeSpend
                        self.commitment.type = type
                        self.commitment.id = id
                        self.progress.stopAnimation(self)
                        self.progress.isHidden = true
                        self.commitment.startTimer()
                    }
                }
            } catch {
                print("JSON Serialization error")
            }
        }).resume()
    }
    
    @IBAction func unpinAction(_ sender: Any) {
        self.progress.isHidden = false
        self.progress.startAnimation(self)
        self.commitment.stopTimer()
        var request = URLRequest(url: URL(string: self.user.homepage+"/api/unpinATask?userId="+String(self.user.userId)+"&type="+self.commitment.type+"&id="+(String)(self.commitment.id)+"&priority="+String(self.commitment.priority)+"&timeSpend="+String(Int(self.commitment.elapsedTime)))!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                if data == nil{
                    return
                }
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
                if json.keys.contains("content"){
                    let content = json["content"] as! String
                    let type = json["type"] as! String
                    let timeSpend = json["timeSpend"] as! Int
                    let id = json["id"] as! Int64
                    let priority = json["priority"] as! Int
                    var done = json["done"] as! Int
                    
                    let totalTask = json["totalTask"] as! Int
                    if done != totalTask{
                        done = done + 1
                    }
                    DispatchQueue.main.async {
                        self.taskText.stringValue = content
                        self.totalTaskLabel.stringValue = "\(totalTask)"
                        
                        self.doneTaskLabel.stringValue = "\(done)"
                        self.commitment.priority = priority
                        self.commitment.timeSpend = timeSpend
                        self.commitment.type = type
                        self.commitment.id = id
                        self.progress.stopAnimation(self)
                        self.progress.isHidden = true
                        self.commitment.startTimer()
                    }
                }
            } catch {
                print("JSON Serialization error")
            }
        }).resume()
    
    }
    
    @IBAction func doneAction(_ sender: Any) {
        self.progress.isHidden = false
        self.progress.startAnimation(self)
        self.commitment.stopTimer()
        var request = URLRequest(url: URL(string: self.user.homepage+"/api/doneATask?userId="+String(self.user.userId)+"&type="+self.commitment.type+"&id="+(String)(self.commitment.id)+"&timeSpend="+String(Int(self.commitment.elapsedTime)))!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                if data == nil{
                    return
                }
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
                if json.keys.contains("content"){
                    let content = json["content"] as! String
                    let type = json["type"] as! String
                    let timeSpend = json["timeSpend"] as! Int
                    let id = json["id"] as! Int64
                    let priority = json["priority"] as! Int
                    var done = json["done"] as! Int
                    
                    let totalTask = json["totalTask"] as! Int
                    if done != totalTask{
                        done = done + 1
                    }
                    DispatchQueue.main.async {
                        self.taskText.stringValue = content
                        self.totalTaskLabel.stringValue = "\(totalTask)"
                        
                        self.doneTaskLabel.stringValue = "\(done)"
                        self.commitment.priority = priority
                        self.commitment.timeSpend = timeSpend
                        self.commitment.type = type
                        self.commitment.id = id
                        self.progress.stopAnimation(self)
                        self.progress.isHidden = true
                        self.commitment.startTimer()
                    }
                }
            } catch {
                print("JSON Serialization error")
            }
        }).resume()
    }
    
    override func close() {
        self.commitment.stopTimer()
        print("ohch. save me. no .... ")
        super.close()
    }
    
    override var windowNibName : NSNib.Name! {
        return NSNib.Name(rawValue: "MyCommitment")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.level = .floating
        window!.styleMask.remove(.resizable)
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        loadUser()
        loadCommitment()
        self.commitment.delegate = self
        self.dreamLabel.stringValue = self.user.dream
        fileNotifications()
    }
    
    var commitment:Commitment = Commitment(content: "",
                                           id:0,
                                           processing:0,
                                           timeSpend:0,
                                           totalTask:0,
                                           type:"",
                                           priority:0,
                                           done:0)

    var user:User = User(account: "",password_md5: "",token: "",userId:0,dream:"")
    let userKey = "User"
    private func loadUser(){
        guard
            let data = UserDefaults.standard.object(forKey: userKey) as? Data,
            let userTemp = NSKeyedUnarchiver.unarchiveObject(with: data) as? User else{
                return
        }
        self.user = userTemp
    }
    
    private func loadCommitment(){
        self.progress.isHidden = false
        self.progress.startAnimation(self)
        var request = URLRequest(url: URL(string: self.user.homepage+"/api/getATask?userId="+String(self.user.userId))!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                if data == nil{
                    return
                }
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
                if json.keys.contains("content"){
                    let content = json["content"] as! String
                    let type = json["type"] as! String
                    let timeSpend = json["timeSpend"] as! Int
                    let id = json["id"] as! Int64
                    let priority = json["priority"] as! Int
                    var done = json["done"] as! Int
                    
                    let totalTask = json["totalTask"] as! Int
                    if done != totalTask{
                        done = done + 1
                    }
                    DispatchQueue.main.async {
                        self.taskText.stringValue = content
                        self.totalTaskLabel.stringValue = "\(totalTask)"
                        
                        self.doneTaskLabel.stringValue = "\(done)"
                        self.commitment.priority = priority
                        self.commitment.timeSpend = timeSpend
                        self.commitment.type = type
                        self.commitment.id = id
                        self.progress.stopAnimation(self)
                        self.progress.isHidden = true
                        self.commitment.startTimer()
                    }
                    //let userId = json["timeSpend"] as! String
                    //let b:Int? = Int(userId)
                }
            } catch {
                print("JSON Serialization error")
            }
        }).resume()
    }
    
    @IBAction func saveAction(_ sender: Any) {
        self.progress.isHidden = false
        self.progress.startAnimation(self)
        self.commitment.stopTimer()
        let url = self.user.homepage+"/api/addAsProcessingTask?content="+self.taskText.stringValue+"&userId="+String(self.user.userId)+"&token="+self.user.token
        let u = URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        var request = URLRequest(url: u!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                if data == nil{
                    return
                }
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
                if json.keys.contains("content"){
                    let content = json["content"] as! String
                    let type = json["type"] as! String
                    let timeSpend = json["timeSpend"] as! Int
                    let id = json["id"] as! Int64
                    let priority = json["priority"] as! Int
                    var done = json["done"] as! Int
                    
                    let totalTask = json["totalTask"] as! Int
                    if done != totalTask{
                        done = done + 1
                    }
                    DispatchQueue.main.async {
                        self.taskText.stringValue = content
                        self.totalTaskLabel.stringValue = "\(totalTask)"
                        
                        self.doneTaskLabel.stringValue = "\(done)"
                        self.commitment.priority = priority
                        self.commitment.timeSpend = timeSpend
                        self.commitment.type = type
                        self.commitment.id = id
                        self.progress.stopAnimation(self)
                        self.progress.isHidden = true
                        self.commitment.startTimer()
                    }
                }
            } catch {
                print("JSON Serialization error")
            }
        }).resume()
        
    }
    
}
